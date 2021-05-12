##################################################
#
# Construction of Credit Card Datasets
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
# cr_use_bc_combine constructs a dataset of credit-card balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads the following datasets:
#   df_acct_1011
#   df_acct_1213
#   df_acct_1415
#   df_acct_1617
#   df_acct_1819
#   df_acct_2021
#   Each dataset represents two years of observations.
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
# Load trade-level credit card datasets
##################################################

# 2010 - 2011
df_acct_1011 = sqlContext.read.parquet("df_acct_1011.parquet")
df_acct_1011.createOrReplaceTempView("df_acct_1011")

# 2012 - 2013
df_acct_1213 = sqlContext.read.parquet("df_acct_1213.parquet")
df_acct_1213.createOrReplaceTempView("df_acct_1213")

# 2014 - 2015
df_acct_1415 = sqlContext.read.parquet("df_acct_1415.parquet")
df_acct_1415.createOrReplaceTempView("df_acct_1415")

# 2016 - 2017
df_acct_1617 = sqlContext.read.parquet("df_acct_1617.parquet")
df_acct_1617.createOrReplaceTempView("df_acct_1617")

# 2018 - 2019
df_acct_1819 = sqlContext.read.parquet("df_acct_1819.parquet")
df_acct_1819.createOrReplaceTempView("df_acct_1819")

# 2020 - 2021
df_acct_2021 = sqlContext.read.parquet("df_acct_2021.parquet")
df_acct_2021.createOrReplaceTempView("df_acct_2021")

##################################################
# Combine credit card datatsets into one file
##################################################

df_acct = spark.sql("SELECT * FROM df_acct_1011 \
                    UNION \
                    SELECT * FROM df_acct_1213 WHERE df_acct_1213.Run_date > DATE('2012-01-01') \
                    UNION \
                    SELECT * FROM df_acct_1415 WHERE df_acct_1415.Run_date > DATE('2014-01-01') \
                    UNION \
                    SELECT * FROM df_acct_1617 WHERE df_acct_1617.Run_date > DATE('2016-01-01') \
                    UNION \
                    SELECT * FROM df_acct_1819 WHERE df_acct_1819.Run_date > DATE('2018-01-01') \
                    UNION \
                    SELECT * FROM df_acct_2021 WHERE df_acct_2021.Run_date > DATE('2020-01-01')")

df_acct.createOrReplaceTempView("df_acct")

# Save working data set
print('Saving data to files...')
df_acct.printSchema()
df_acct.write.parquet(path="df_acct.parquet", mode="overwrite")

##################################################
# Aggregate trade-level data to consumer level 
##################################################

df_acct = sqlContext.read.parquet("df_acct.parquet")
df_acct.createOrReplaceTempView("df_acct")

# Already excluded:
# 1. outdated accounts
# 2. legacy accounts that are fully paid (PD) / charged off (WO)

df_ind = spark.sql("SELECT TU_Consumer_ID, Run_date, \
                     SUM(CURRENT_BALANCE) AS bc_bal, \
                     SUM(IF(MOP RLIKE '[4-5]', CURRENT_BALANCE, 0)) AS bc_bal_arr, \
                     SUM(IF(MOP RLIKE '[7-9]', CURRENT_BALANCE, 0)) AS bc_bal_def, \
                     SUM(CURRENT_BALANCE/n_now) AS bc_bal_ind, \
                     SUM(IF(MOP RLIKE '[4-5]', CURRENT_BALANCE/n_now, 0)) AS bc_bal_arr_ind, \
                     SUM(IF(MOP RLIKE '[7-9]', CURRENT_BALANCE/n_now, 0)) AS bc_bal_def_ind, \
                     SUM(chargoff_refine) AS bc_chargoff, \
                     SUM(chargoff_refine/n_now) AS bc_chargoff_ind, \
                     SUM(IF(new_file RLIKE 'legacy', 0, CURRENT_BALANCE)) AS bal_excl_legacy, \
                     SUM(IF(new_file RLIKE 'legacy', 0, CURRENT_BALANCE/n_now)) AS bal_excl_legacy_ind, \
                     SUM(IF(new_file RLIKE 'legacy', 0, chargoff_refine)) AS chargoff_excl_legacy, \
                     SUM(IF(new_file RLIKE 'legacy', 0, chargoff_refine/n_now)) AS chargoff_excl_legacy_ind \
                   FROM df_acct \
                   GROUP BY TU_Consumer_ID, Run_date ")

df_ind.createOrReplaceTempView("df_ind")

# Exclude legacy accounts for individual-level changes (so as updates from previously outdated accounts)
# Be very cautious while interpreting changes: potentially mismeasured due to missing observations from non-reporting FIs
# Special case: e.g. new accounts may be switching from other non-reporting FIs
# Legacy accounts may show up as new due to misreporting opened dates
df_ind = spark.sql("SELECT df_now.*, \
                     df_now.bal_excl_legacy - df_last.bc_bal AS bc_bal_chg, \
                     df_now.bal_excl_legacy_ind - df_last.bc_bal_ind AS bc_bal_chg_ind, \
                     df_now.chargoff_excl_legacy - df_last.bc_chargoff AS bc_chargoff_chg, \
                     df_now.chargoff_excl_legacy_ind - df_last.bc_chargoff_ind AS bc_chargoff_chg_ind \
                   FROM df_ind AS df_now \
                   LEFT JOIN df_ind AS df_last \
                     ON df_last.TU_Consumer_ID = df_now.TU_Consumer_ID \
                     AND df_last.Run_date = add_months(df_now.Run_date,-1) ") \
         .drop("bal_excl_legacy","bal_excl_legacy_ind","chargoff_excl_legacy","chargoff_excl_legacy_ind")

df_ind.createOrReplaceTempView("df_ind")

# Exclude fully paid (PD) / charged off (WO) accounts for number of accounts, credit limit, and credit score at origination
df_ind_active = spark.sql("SELECT TU_Consumer_ID, Run_date, \
                            COUNT(TU_Trade_ID) AS N_bc, \
                            SUM(cr_lmt) AS bc_lmt, \
                            SUM(cr_lmt/n_now) AS bc_lmt_ind, \
                            SUM(cr_lmt*as115_origin_grp)/SUM(cr_lmt) AS bc_crsc_grp, \
                            SUM(cr_lmt*as115_origin)/SUM(cr_lmt) AS bc_crsc \
                          FROM df_acct \
                          WHERE terminal NOT RLIKE '(PD|WO)' \
                          GROUP BY TU_Consumer_ID, Run_date ")

df_ind_active.createOrReplaceTempView("df_ind_active")

df_ind = spark.sql("SELECT df_ind.*, \
                     df_ind_active.N_bc, \
                     df_ind_active.bc_lmt, df_ind_active.bc_lmt_ind, \
                     df_ind_active.bc_crsc_grp, df_ind_active.bc_crsc \
                   FROM df_ind \
                   LEFT JOIN df_ind_active \
                     ON df_ind.TU_Consumer_ID = df_ind_active.TU_Consumer_ID \
                     AND df_ind.Run_date = df_ind_active.Run_date ")

df_ind.createOrReplaceTempView("df_ind")

##################################################
# Save the final dataset and close the connection
##################################################


# Save working data set
print('Saving data to files...')
df_ind.printSchema()
df_ind.write.parquet(path="df_ind.parquet", mode="overwrite")

# Stop the sparkContext and cluster after processing
sc.stop()

##################################################
# End
##################################################
