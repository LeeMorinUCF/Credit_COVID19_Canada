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
# tu_sample_AB_bc constructs a dataset of credit-card balances.
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

##################################################
# Sampling 
##################################################

# Joint with CRC
df_ind = spark.sql("SELECT df_ind.*, df_crc.age, df_crc.prov, df_crc.as115 \
                   FROM df_ind \
                   LEFT JOIN df_crc \
                     ON df_ind.TU_Consumer_ID = df_crc.tu_consumer_id \
                     AND df_ind.archive_ym = df_crc.Run_Date ").drop("archive_ym") \
         .where("Run_date >= DATE('2012-01-01')").where("Run_date <= DATE('2017-01-01')")

df_ind.createOrReplaceTempView("df_ind")

# Identify sampled consumers
df_cid = df_ind.where("prov LIKE 'AB'").select("TU_Consumer_ID").distinct().sample(withReplacement=False, fraction=0.10, seed=42)

df_cid.createOrReplaceTempView("df_cid")

# Sampling individual files
df_ind = spark.sql("SELECT df_ind.* \
                     FROM df_ind \
                     INNER JOIN df_cid \
                       ON df_ind.TU_Consumer_ID = df_cid.TU_Consumer_ID ")

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
