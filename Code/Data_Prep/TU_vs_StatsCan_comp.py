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
# B0C_vs_StatsCan_comp constructs a dataset of counts of credit-card consumers.
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
#   This version calculates the total number of consumers
#   within regions in Canada, for comparison with figures from Statistics Canada. 
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

# Load files for credit card data
df_ind = sqlContext.read.parquet("/path/to/df_ind/files/BC/df_ind.parquet") \
  .withColumn("archive_ym", year("Run_date")*100 +month("Run_date"))

df_ind.createOrReplaceTempView("df_ind")

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

# Further consolidate provinces into regions.
df_crc = spark.sql("SELECT *, \
                     CASE WHEN prov RLIKE '(ON|QC|NS|NB|MB|BC|PE|SK|AB|NL|NT|YT|NU)' THEN prov \
                       WHEN prov RLIKE '(NS|NB|PE||NL)' THEN 'ATL' \
                       WHEN prov RLIKE '(NT|YT|NU)' THEN 'CAT' \
                     END AS region \
                   FROM df_crc ")

df_crc.createOrReplaceTempView("df_crc")


##################################################
# Aggregating accounts by region 
##################################################

# Joint with CRC and select unique consumer IDs within 2016. 
df_ind = spark.sql("SELECT DISTINCT df_ind.tu_consumer_id, df_crc.region \
                   FROM df_ind \
                   LEFT JOIN df_crc \
                     ON df_ind.TU_Consumer_ID = df_crc.tu_consumer_id \
                     AND df_ind.archive_ym = df_crc.Run_Date ").drop("archive_ym") \
             .where("Run_date >= DATE('2016-01-01')") \
             .where("Run_date <= DATE('2016-12-01')") \
             .where("age >= 20")

df_ind.createOrReplaceTempView("df_ind")

# Sum the number of account holders in 2016.
df_ind = spark.sql("SELECT df_crc.region, COUNT(tu_consumer_id) AS N_geq_20_BC \
                   FROM df_ind \
                GROUP BY region")

df_ind.createOrReplaceTempView("df_ind")


##################################################
# Save the final dataset and close the connection
##################################################

print('Saving data to files...')
df_ind.printSchema()
df_ind.write.csv(path="df_ind_folder", mode="overwrite", sep=",", header="true")

# Stop the sparkContext and cluster after processing
sc.stop()

##################################################
# End
##################################################
