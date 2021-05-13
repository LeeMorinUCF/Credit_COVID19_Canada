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
# tu_sample_heloc constructs a dataset of HELOC balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads the dataset df_ind, which records HELOC balances
#   aggregated across all accounts held by individual consumers. 
#   The dataset df_ind is generated from the script cr_use_heloc_combine.py, 
#   which is the last script run in the script df_ind_heloc.slurm. 
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

# Load files for HELOC data
df_ind = sqlContext.read.parquet("/path/to/df_ind/files/HE/df_ind.parquet")
df_ind.createOrReplaceTempView("df_ind")

##################################################
# Sampling 
##################################################

# Identify sampled consumers
df_cid = df_ind.select("TU_Consumer_ID").distinct().sample(withReplacement=False, fraction=0.10, seed=42)

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
