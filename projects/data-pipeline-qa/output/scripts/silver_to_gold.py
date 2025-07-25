from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, window

spark = SparkSession.builder \
    .appName("SilverToGold") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.spark_catalog.type", "hadoop") \
    .config("spark.sql.catalog.spark_catalog.warehouse", "s3://<gold_bucket>/gold_iot_data/") \
    .getOrCreate()

# Read from silver
df = spark.readStream.table("spark_catalog.iot_db.silver_iot_data")

# Aggregate data (e.g., average readings per device per 15-minute window)
df_agg = df.groupBy(
    window("timestamp", "15 minutes"),
    "device_id",
    "readings.temperature.unit",
    "readings.humidity.unit",
    "readings.battery_level.unit"
).agg(
    avg("readings.temperature.value").alias("avg_temperature"),
    avg("readings.humidity.value").alias("avg_humidity"),
    avg("readings.battery_level.value").alias("avg_battery_level")
)

# Write to gold
query = df_agg.writeStream \
    .format("iceberg") \
    .outputMode("complete") \
    .option("checkpointLocation", "s3://<gold_bucket>/checkpoints/") \
    .table("spark_catalog.iot_db.gold_iot_data")

query.awaitTermination()