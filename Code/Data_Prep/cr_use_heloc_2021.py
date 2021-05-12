
##################################################
#
# Construction of HELOC Datasets
#
# Anson T.Y. Ho, Ph.D.
# Assistant Professor
# Department of Real Estate Management
# Ryerson University
#
# May 12, 2021
#
##################################################
#
# cr_use_heloc_Y1Y2 constructs a dataset of HELOC balances
#   representing two years of observations (20Y1 and 20Y2).
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Access to the TransUnion database.
#
#
##################################################

##################################################
# Initialize PySpark Session 
##################################################

from pyspark.sql import SQLContext, SparkSession, Row
from pyspark import *
from pyspark.sql.functions import * # Call SparkSQL native functions such as abs, sqrt...
from pyspark.sql.types import DateType

spark=SparkSession\
.builder\
.appName("Python Spark Dataframe")\
.config(conf = SparkConf())\
.getOrCreate()

sc = spark.sparkContext
sqlContext = SQLContext(sc)

##################################################
# Comments / Remarks
##################################################

# Exclude:
# 1. *outdated accounts*
# 2. legacy accounts that are fully paid (PD) / charged off (WO)
# 3. legacy accounts for individual-level changes (so as updates from previously outdated accounts)
# 4. fully paid (PD) / charged off (WO) accounts for number of accounts, credit limit, and credit score at origination

# Caution with the first period of data (at least for measuring new account and the total charged offs) because:
# (1) accounts opened in previous quarters are identified as new accounts
#     WORKAROUND: use OPENED_date instead of Run_date, still it captures more new accounts in the first period of data
# (2) unable to determine if legacy accounts are charged off in the current period
#     i.e. FI may keep updating TU on charged off accounts
#     WORKAROUND: drop new_file LIKE 'legacy' AND terminal LIKE 'WO' - likely to underestimate WO in the first month/quarter

# CLOSED_date is not always populated with terminal LIKE '(WO|PD|AC)' for the following reasons:
# (1) charged off but not closed by FIs
# (2) CLOSED_date missing with CLOSED_INDIC LIKE 'Y'

##################################################
# Loading source files 
##################################################

# Load files for CRC data
df_crc = sqlContext.read.parquet("/appdata/TU/TU_Official/CRCS_LDU/crcs_ldu_*-01_parq") \
  .select("tu_consumer_id", "Run_Date", "as115").replace(0, None, subset="as115")

df_crc.createOrReplaceTempView("df_crc")

# Load files for trade-level data
df_acct = sqlContext.read.parquet("/appdata/TU/TU_Official/Account/account_202[0-1]-*-01_parq") \
  .select("TU_Consumer_ID","TU_Trade_ID","Joint_Account_ID","Primary_Indicator","ACCT_TYPE","PRODUCT_TYPE", \
          "BEST_AMT_FLAG","CREDIT_LIMIT","HIGH_CREDIT_AMT","NARRATIVE_CODE1","NARRATIVE_CODE2","CLOSED_INDIC", \
          "CURRENT_BALANCE","CHARGOFF_AMT","MOP","L3","TERMS_DUR","TERMS_FREQUENCY","TERMS_AMT","PAYMT_PAT","MONTHS_REVIEWED","PAYMT_AMT", \
          "ACTIVITY_PERIOD",col("TU_acct_num").alias("BIN"), \
          to_date("Run_date").alias("Run_date"), \
          to_date(concat(col("LAST_UPDATED_DT").substr(1,4),lit("-"), \
            col("LAST_UPDATED_DT").substr(5,2),lit("-"), \
            col("LAST_UPDATED_DT").substr(7,2))).alias("LAST_UPDATED_date"), \
          to_date(concat(col("OPENED_DT").substr(1,4),lit("-"), \
                         col("OPENED_DT").substr(5,2),lit("-"), \
                         col("OPENED_DT").substr(7,2))).alias("OPENED_date"), \
          to_date(concat(col("CLOSED_DT").substr(1,4),lit("-"), \
                         col("CLOSED_DT").substr(5,2),lit("-"), \
                         col("CLOSED_DT").substr(7,2))).alias("CLOSED_date"), \
          to_date(concat(col("FILE_SINCE_DT").substr(1,4),lit("-"), \
                         col("FILE_SINCE_DT").substr(5,2),lit("-"), \
                         col("FILE_SINCE_DT").substr(7,2))).alias("FILE_SINCE_date") ) \
  .replace(0, None, subset="TERMS_DUR").replace(0, None, subset="TERMS_AMT") \
  .where("PRODUCT_TYPE LIKE 'HE'").where("Run_date <= DATE('2022-01-01')")

# length(regexp_extract(col("PAYMT_PAT"),'^[3-9]+([3-9X]+[^0-1X])?',0)).alias("n_cont_arr")
# length(regexp_replace(col("PAYMT_PAT").substr(1,12),'X*[0-2]+X*','')).alias("n_arr_12m")

df_acct.createOrReplaceTempView("df_acct")

##################################################
# Define new variables 
##################################################

# Refine credit limit and charge-off amount
df_acct = spark.sql("SELECT *, \
                      CASE WHEN BEST_AMT_FLAG LIKE 'C' THEN GREATEST(CREDIT_LIMIT, CURRENT_BALANCE) \
                        WHEN BEST_AMT_FLAG LIKE 'H' THEN GREATEST(HIGH_CREDIT_AMT, CURRENT_BALANCE) \
                        ELSE GREATEST(IFNULL(CREDIT_LIMIT,0),IFNULL(HIGH_CREDIT_AMT,0),CURRENT_BALANCE) END AS cr_lmt, \
                      CASE WHEN BEST_AMT_FLAG LIKE 'C' THEN CREDIT_LIMIT \
                        WHEN BEST_AMT_FLAG LIKE 'H' THEN HIGH_CREDIT_AMT \
                        ELSE NULL END AS cr_lmt_woadj, \
                      CASE \
                        WHEN NARRATIVE_CODE1 RLIKE '^(TC)$' OR NARRATIVE_CODE2 RLIKE '^(TC)$' THEN GREATEST(CURRENT_BALANCE,IFNULL(CHARGOFF_AMT,0)) \
                        WHEN (NARRATIVE_CODE1 RLIKE '^(WO)$' OR NARRATIVE_CODE2 RLIKE '^(WO)$') AND IFNULL(CHARGOFF_AMT,0)=0 THEN CURRENT_BALANCE \
                        ELSE IFNULL(CHARGOFF_AMT,0) END AS chargoff_refine \
                    FROM df_acct ") \
          .drop("BEST_AMT_FLAG","HIGH_CREDIT_AMT","CREDIT_LIMIT","CHARGOFF_AMT","NARRATIVE_CODE1","NARRATIVE_CODE2")

df_acct.createOrReplaceTempView("df_acct")

# Calculate required monthly payment, refine term payment amount - inconsistency in A, E, (L), (Q), T, (R)
df_acct = spark.sql("SELECT *, \
                      CASE \
                        WHEN TERMS_FREQUENCY LIKE 'A' THEN TERMS_AMT*2 \
                        WHEN TERMS_FREQUENCY LIKE 'B' THEN TERMS_AMT*2.16 \
                        WHEN TERMS_FREQUENCY LIKE 'D' THEN TERMS_AMT*0 \
                        WHEN TERMS_FREQUENCY LIKE 'E' THEN TERMS_AMT*2 \
                        WHEN TERMS_FREQUENCY LIKE 'L' THEN TERMS_AMT*1/2 \
                        WHEN TERMS_FREQUENCY LIKE 'M' THEN TERMS_AMT \
                        WHEN TERMS_FREQUENCY LIKE 'P' THEN TERMS_AMT*0 \
                        WHEN TERMS_FREQUENCY LIKE 'Q' THEN TERMS_AMT*1/3 \
                        WHEN TERMS_FREQUENCY LIKE 'R' THEN TERMS_AMT*1/4 \
                        WHEN TERMS_FREQUENCY LIKE 'S' THEN TERMS_AMT*1/6 \
                        WHEN TERMS_FREQUENCY LIKE 'T' THEN TERMS_AMT*1/4 \
                        WHEN TERMS_FREQUENCY LIKE 'W' THEN TERMS_AMT*4.33 \
                        WHEN TERMS_FREQUENCY LIKE 'Y' THEN TERMS_AMT*1/12 \
                        ELSE TERMS_AMT END AS TERMS_PAY \
                    FROM df_acct ") \
          .drop("TERMS_FREQUENCY","TERMS_AMT")

df_acct.createOrReplaceTempView("df_acct")

##################################################
# Sample cleaning 
##################################################

df_acct = df_acct.where("CURRENT_BALANCE IS NOT NULL").where("NOT (cr_lmt=0 OR cr_lmt IS NULL)") \
                 .where("LAST_UPDATED_date >= add_months(Run_date,-3)")

df_acct.createOrReplaceTempView("df_acct")

# NOT all TU_Trade_IDs get updated by FI, even though they share the same Joint_Account_ID
# Screening out accounts based on the following logic may introduce miscounting in the number of account holders
# and/or accidentally drop some of the joint account holders when .where(Primary_Indicator=0) is used
#                 .where("DATEDIFF(add_months(Run_date,-3),LAST_UPDATED_date)<0")

# downward biased in arrears roll-out transition calculation if the follow filters are applied
#                 .where("NOT (CURRENT_BALANCE = 0)").where("MOP NOT RLIKE '[8-9]'")

##################################################
# Create lagged variables for trade data 
##################################################

df_acct = spark.sql("SELECT df_now.*, \
                      CASE WHEN df_last.TU_Trade_ID IS NULL THEN \
                        CASE WHEN df_now.OPENED_date >= add_months(df_now.Run_date,-6) \
                          THEN 'new' ELSE 'legacy' END \
                        ELSE 'exist' END AS new_file, \
                      CASE \
                        WHEN (df_now.CURRENT_BALANCE=0 AND (df_now.CLOSED_INDIC LIKE 'Y' OR df_now.ACCT_TYPE RLIKE '^(M|I)$')) THEN 'PD' \
                        WHEN (df_now.CURRENT_BALANCE>0 AND (df_now.chargoff_refine>=df_now.CURRENT_BALANCE)) THEN 'WO' \
                        WHEN (df_now.CURRENT_BALANCE>0 AND (df_now.CLOSED_INDIC LIKE 'Y')) THEN 'AC' \
                        ELSE 'N' END AS terminal, \
                      SUBSTR(df_now.PAYMT_PAT, GREATEST(df_now.MONTHS_REVIEWED-IFNULL(df_last.MONTHS_REVIEWED,0)+1, 2), 1) AS MOP_last, \
                      df_now.CURRENT_BALANCE-IFNULL(df_last.CURRENT_BALANCE,0) AS bal_chg, \
                      df_now.cr_lmt-IFNULL(df_last.cr_lmt,0) AS cr_lmt_chg, \
                      df_now.chargoff_refine-IFNULL(df_last.chargoff_refine,0) AS chargoff_chg, \
                      df_now.TERMS_PAY-IFNULL(df_last.TERMS_PAY,0) AS TERMS_PAY_chg \
                    FROM df_acct AS df_now \
                    LEFT JOIN df_acct AS df_last \
                      ON (df_last.Run_date = add_months(df_now.Run_date,-1)) \
                      AND (df_last.TU_Trade_ID = df_now.TU_Trade_ID) \
                    WHERE \
                      df_last.TU_Trade_ID IS NULL OR \
                      ( df_last.TU_Trade_ID IS NOT NULL AND \
                        NOT ( (df_last.CURRENT_BALANCE=0 AND df_now.CURRENT_BALANCE=0) AND (df_last.CLOSED_INDIC LIKE 'Y' OR df_last.ACCT_TYPE RLIKE '^(M|I)$') ) AND \
                        NOT ( (df_last.chargoff_refine>0) AND (df_last.chargoff_refine>=df_last.CURRENT_BALANCE) ) ) ") \
          .where("NOT(new_file RLIKE 'legacy' AND terminal RLIKE '(PD|WO)')") \
          .drop("MONTHS_REVIEWED","PAYMT_PAT","CLOSED_INDIC","ACCT_TYPE","PRODUCT_TYPE")
#          .drop("FILE_SINCE_date", "LAST_UPDATED_date")

# Possible to calculate account-level changes using the above logic
# But the result will not be right if outdated accounts are discarded, because changes due to discarding accounts is not taken into account
# e.g. mortgage renewed/ported to another FI, possibly causing the old account to be outdated

# WHERE clause is used to reduce file size
# The conditions filter out accounts that are PREVIOUSLY PAID OR COMPLETELY CHARGED OFF, with account abnormalities taken into account
# Known issues that may affect the count of number of account holders:
# 1. closed accounts with zero balance reopened with positive balance in the current period
# 2. Time lag in reporting closed accounts, esp. for non-primary holders
# 3. M and I with completed payment but not indicated as closed
# 4. CHARGOFF_AMT may be missing or =0 for accounts charged off with narrative code "WO"

df_acct.createOrReplaceTempView("df_acct")

###########################################################
# Merge trade-level data with consumer CRC 
# at origination of HELOC account
###########################################################

# Consolidate account opened date for CRC matching
df_acct = spark.sql("SELECT *, \
                      CASE WHEN YEAR(OPENED_date)>=2009 THEN YEAR(OPENED_date)*100 +month(OPENED_date) ELSE \
                        CASE WHEN MONTH(OPENED_date) BETWEEN 1 AND 3 THEN YEAR(OPENED_date)*100 +1 \
                          WHEN MONTH(OPENED_date) BETWEEN 4 AND 6 THEN YEAR(OPENED_date)*100 +4 \
                          WHEN MONTH(OPENED_date) BETWEEN 7 AND 9 THEN YEAR(OPENED_date)*100 +7 \
                          WHEN MONTH(OPENED_date) BETWEEN 10 AND 12 THEN YEAR(OPENED_date)*100 +10 \
                          ELSE NULL END \
                      END AS open_ym \
                    FROM df_acct")
# .drop("OPENED_date")

df_acct.createOrReplaceTempView("df_acct")

# Merge credit scores on account opened date to trade-level data
df_acct = spark.sql("SELECT df_acct.*, \
                      df_crc.as115 AS as115_open \
                    FROM df_acct \
                    LEFT JOIN df_crc \
                      ON df_crc.tu_consumer_id = df_acct.TU_Consumer_ID \
                      AND df_crc.Run_Date = df_acct.open_ym")

df_acct.createOrReplaceTempView("df_acct")

# Create 2003-07 average credit score for consumer-level CRC
df_crc_avg = spark.sql("SELECT TU_Consumer_ID, \
                         AVG(as115) AS as115_avg \
                       FROM df_crc \
                       WHERE Run_Date BETWEEN 200301 AND 200712 \
                       GROUP BY TU_Consumer_ID")

df_crc_avg.createOrReplaceTempView("df_crc_avg")

# Merge 2003-07 average credit score to trade-level data
df_acct = spark.sql("SELECT df_acct.*, \
                      df_crc_avg.as115_avg \
                    FROM df_acct \
                    LEFT JOIN df_crc_avg \
                      ON df_crc_avg.TU_Consumer_ID = df_acct.TU_Consumer_ID")

df_acct.createOrReplaceTempView("df_acct")

# Consolidate consumer credit scores at origination
df_acct = spark.sql("SELECT *, \
                      CASE WHEN as115_open IS NOT NULL THEN as115_open \
                        ELSE CASE WHEN open_ym<200301 THEN as115_avg ELSE NULL END \
                        END AS as115_origin \
                    FROM df_acct") \
          .drop("open_ym","as115_open","as115_avg")

df_acct.createOrReplaceTempView("df_acct")

##################################################
# Create group CRC from trade-level data 
# (average consumer risk score across all 
# authorized users on each card)
##################################################

# Create group CRC based on ALL account holders CRCs
df_gcrc = spark.sql("SELECT Run_date, Joint_Account_ID, \
                      AVG(as115_origin) AS as115_origin_grp, \
                      COUNT(TU_Consumer_ID) AS n_now \
                    FROM df_acct \
                    GROUP BY Run_date, Joint_Account_ID ")

df_gcrc.createOrReplaceTempView("df_gcrc")

# Merge group CRC to trade-level data
df_acct = spark.sql("SELECT df_acct.*, \
                      df_gcrc.as115_origin_grp, \
                      df_gcrc.n_now \
                    FROM df_acct \
                    LEFT JOIN df_gcrc \
                      ON df_acct.Joint_Account_ID = df_gcrc.Joint_Account_ID \
                      AND df_acct.Run_date = df_gcrc.Run_date ")

df_acct.createOrReplaceTempView("df_acct")

##################################################
# Save the final dataset and close the connection
##################################################

print('Saving data to files...')
df_acct.printSchema()
df_acct.write.parquet(path="df_acct_2021.parquet", mode="overwrite")

# Stop the sparkContext and cluster after processing
sc.stop()

##################################################
# End
##################################################