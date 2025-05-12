from pyspark.sql import SparkSession
from pyspark.sql.functions import col, window,sum
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType,LongType

spark = SparkSession.builder \
    .appName("StreamPipeline") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

schema = StructType([
    StructField("nome", StringType(), True),         
    StructField("idade", IntegerType(), True),       
    StructField("cidade", StringType(), True),         
    StructField("timestamp", TimestampType(), True), 
    StructField("valor_conta", LongType(), True)     
])

df_stream_users = spark.readStream.options(delimiter=';',header= True).csv("/opt/spark/data/input_csv/input*", schema = schema)

df_users_filter = (
    df_stream_users.filter(col('idade') < 40)
)

df_agg = df_users_filter \
    .withWatermark("timestamp", "1 minute") \
    .groupBy(window(col("timestamp"), "1 minute"), col("cidade")) \
    .agg(sum("valor_conta").alias("total_valor_conta"))

query_console = (df_agg.writeStream \
    .outputMode("append") \
    .format("console") \
    .option("truncate", False) \
    .start()
)

query_parquet = (df_agg.writeStream.outputMode("append").format("parquet")
.options(
        path = f"/opt/spark/data/output",
        checkpointLocation = f"/opt/spark/data/checkpoint"
    ).start())


query_console.awaitTermination()
query_parquet.awaitTermination()
