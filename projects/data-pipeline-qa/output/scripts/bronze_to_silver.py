from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.anomaly import IsolationForest
import json

spark = SparkSession.builder \
    .appName("BronzeToSilver") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.spark_catalog.type", "hadoop") \
    .config("spark.sql.catalog.spark_catalog.warehouse", "s3://<silver_bucket>/silver_iot_data/") \
    .getOrCreate()

schema = StructType([
    StructField("schema_version", StringType(), False),
    StructField("device_id", StringType(), False),
    StructField("timestamp", TimestampType(), False),
    StructField("location", StructType([
        StructField("latitude", DoubleType(), False),
        StructField("longitude", DoubleType(), False)
    ]), False),
    StructField("readings", StructType([
        StructField("temperature", StructType([
            StructField("value", DoubleType(), False),
            StructField("unit", StringType(), False)
        ]), False),
        StructField("humidity", StructType([
            StructField("value", DoubleType(), False),
            StructField("unit", StringType(), False)
        ]), False),
        StructField("battery_level", StructType([
            StructField("value", DoubleType(), False),
            StructField("unit", StringType(), False)
        ]), False)
    ]), False),
    StructField("status", StringType(), False)
])

# Read from Avro in bronze
df = spark.readStream.format("avro").schema(schema).load("s3://<bronze_bucket>/bronze_data/")

# Metrics collection
metrics = df.groupBy().count().withColumn("file_size", spark._jvm.org.apache.spark.sql.functions.input_file_name().size())
metrics.writeStream \
    .format("iceberg") \
    .outputMode("append") \
    .option("checkpointLocation", "s3://<metrics_bucket>/checkpoints/") \
    .table("spark_catalog.iot_db.pipeline_metrics")

# Schema drift detection using IsolationForest
assembler = VectorAssembler(
    inputCols=["location.latitude", "location.longitude", "readings.temperature.value", "readings.humidity.value", "readings.battery_level.value"],
    outputCol="features"
)
df_assembled = assembler.transform(df)
isolation_forest = IsolationForest(contamination=0.01, randomSeed=42)
model = isolation_forest.fit(df_assembled)
df_with_anomalies = model.transform(df_assembled)

# Filter out anomalies and write to silver
df_clean = df_with_anomalies.filter(df_with_anomalies["anomaly"] == 0)
query = df_clean.writeStream \
    .format("iceberg") \
    .outputMode("append") \
    .option("checkpointLocation", "s3://<silver_bucket>/checkpoints/") \
    .table("spark_catalog.iot_db.silver_iot_data")

query.awaitTermination()