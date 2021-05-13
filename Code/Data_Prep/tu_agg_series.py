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
# tu_agg_series calculates aggregate statistics for either 
#   credit-card balances or HELOC loans, depending on
#   which set of data are loaded into the df_acct_Y1Y2 dtasets. 
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
# Aggregate trade-level data by Run_Date
##################################################

df_acct = sqlContext.read.parquet("df_acct.parquet")
df_acct.createOrReplaceTempView("df_acct")

# Already excluded:
# 1. outdated accounts
# 2. legacy accounts that are fully paid (PD) / charged off (WO)


# Calculate aggregate time series from account balances.
df_agg = spark.sql("SELECT df_acct.Run_date, \
                     AVERAGE(df_acct.CURRENT_BALANCE) AS bal_avg, \
                     STDEV(df_acct.CURRENT_BALANCE) AS bal_sd, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.25) AS bal_p25, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.50) AS bal_p50, \
                     PERCENTILE(df_acct.CURRENT_BALANCE, 0.75) AS bal_p75, \
                   FROM df_acct \
                   WHERE terminal NOT RLIKE '(PD|WO)' \
                   GROUP BY Run_date ") \
         .where("Run_date >= DATE('2017-01-01')").where("Run_date <= DATE('2021-01-01')")

df_agg.createOrReplaceTempView("df_agg")


##################################################
# Save the final dataset and close the connection
##################################################


# Save working data set
print('Saving data to files...')
df_agg.printSchema()
df_agg.write.parquet(path="df_ind_folder", mode="overwrite")

# Stop the sparkContext and cluster after processing
sc.stop()

##################################################
# End
##################################################
