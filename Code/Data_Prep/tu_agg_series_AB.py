##################################################
#
# Construction of Aggregate Series for either Credit Card 
# or HELOC Datasets
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
# tu_agg_series_AB_bc constructs a dataset of aggregate statistics, 
#   in the province of Alberta, for either 
#   credit-card balances or HELOC loans, depending on
#   which set of data are loaded into the df_acct_Y1Y2 datasets.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads the dataset df_ind, which records credit card balances
#   aggregated across all accounts held by individual consumers. 
#   The dataset df_ind is generated from the script cr_use_bc_combine.py, 
#   which is the last script run in the script df_ind_bc.slurm. 
#   This version selects a sample from the province of Alberta. 
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
# Create variable to indicate province
##################################################

# Load files for CRC data
df_crc = sqlContext.read.parquet("/appdata/TU/TU_Official/CRCS_LDU/crcs_ldu_*_parq") \
  .select("tu_consumer_id", "Run_Date", "fsa", "go30", "go90", "as115", "cvsc100") \
  .replace(0, None, subset="as115").replace(-8, None, subset="cvsc100").replace(0, None, subset="cvsc100")

df_crc.createOrReplaceTempView("df_crc")

# Create age groups and refine consumer province
df_crc = spark.sql("SELECT *, \
                     CASE WHEN go30/12 > 10 THEN go30/12 ELSE go30 END AS age, \
                     CASE WHEN fsa LIKE 'T%' THEN 'AB' \
                       WHEN fsa LIKE 'K%' OR fsa LIKE 'L%' OR fsa LIKE 'M%' OR fsa LIKE 'N%' OR fsa LIKE 'P%' THEN 'ON' \
                       WHEN fsa LIKE 'G%' OR fsa LIKE 'J%' OR fsa LIKE 'H%' THEN 'QC' \
                       WHEN fsa LIKE 'B%' THEN 'NS' \
                       WHEN fsa LIKE 'E%' THEN 'NB' \
                       WHEN fsa LIKE 'R%' THEN 'MB' \
                       WHEN fsa LIKE 'V%' THEN 'BC' \
                       WHEN fsa LIKE 'C%' THEN 'PE' \
                       WHEN fsa LIKE 'S%' THEN 'SK' \
                       WHEN fsa LIKE 'A%' THEN 'NL' \
                       WHEN fsa LIKE 'X%' THEN 'NT' \
                       WHEN fsa LIKE 'Y%' THEN 'YT' \
                       ELSE CASE WHEN go90 RLIKE '(ON|QC|NS|NB|MB|BC|PE|SK|AB|NL|NT|YT|NU)' THEN go90 ELSE NULL END \
                     END AS prov \
                   FROM df_crc ") \
         .drop("go30","go90")

df_crc.createOrReplaceTempView("df_crc")

##################################################
# Aggregate trade-level data by Run_Date
##################################################

# Joint with CRC
df_acct = spark.sql("SELECT df_acct.*, df_crc.age, df_crc.prov, df_crc.as115 \
                   FROM df_ind \
                   LEFT JOIN df_crc \
                     ON df_acct.TU_Consumer_ID = df_crc.tu_consumer_id \
                     AND df_acct.archive_ym = df_crc.Run_Date ").drop("archive_ym") \
         .where("Run_date >= DATE('2012-01-01')").where("Run_date <= DATE('2017-01-01')") \
             .where("prov LIKE 'AB'")



# Calculate aggregate time series from account balances.
df_agg = spark.sql("SELECT df_acct.Run_date, \
                     AVERAGE(df_acct.CURRENT_BALANCE) AS bal_avg, \
                     STDEV(df_acct.CURRENT_BALANCE) AS bal_sd, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.25) AS bal_p25, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.50) AS bal_p50, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.75) AS bal_p75, \
                   FROM df_ind \
                   WHERE terminal NOT RLIKE '(PD|WO)' \
                   GROUP BY Run_date ")

df_agg.createOrReplaceTempView("df_agg")


##################################################
# Save the final dataset and close the connection
##################################################

print('Saving data to files...')
df_agg.printSchema()
df_agg.write.csv(path="df_ind_folder", mode="overwrite", sep=",", header="true")

# Stop the sparkContext and cluster after processing
sc.stop()

##################################################
# End
##################################################
