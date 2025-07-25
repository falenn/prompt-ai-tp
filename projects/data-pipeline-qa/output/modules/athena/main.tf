resource "aws_athena_workgroup" "iot_workgroup" {
  name = "iot_workgroup"
  configuration {
    result_configuration {
      output_location = "s3://${var.silver_bucket}/athena-results/"
    }
  }
}

resource "aws_glue_catalog_table" "silver_table" {
  database_name = aws_glue_catalog_database.iot_db.name
  name          = "silver_iot_data"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    "table_type" = "ICEBERG"
  }
  storage_descriptor {
    location = "s3://${var.silver_bucket}/silver_iot_data/"
    input_format = "org.apache.iceberg.hadoop.HadoopInputFormat"
    output_format = "org.apache.iceberg.hadoop.HadoopOutputFormat"
  }
}

resource "aws_glue_catalog_table" "gold_table" {
  database_name = aws_glue_catalog_database.iot_db.name
  name          = "gold_iot_data"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    "table_type" = "ICEBERG"
  }
  storage_descriptor {
    location = "s3://${var.gold_bucket}/gold_iot_data/"
    input_format = "org.apache.iceberg.hadoop.HadoopInputFormat"
    output_format = "org.apache.iceberg.hadoop.HadoopOutputFormat"
  }
}

resource "aws_glue_catalog_table" "metrics_table" {
  database_name = aws_glue_catalog_database.iot_db.name
  name          = "pipeline_metrics"
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    "table_type" = "ICEBERG"
  }
  storage_descriptor {
    location = "s3://${var.metrics_bucket}/pipeline_metrics/"
    input_format = "org.apache.iceberg.hadoop.HadoopInputFormat"
    output_format = "org.apache.iceberg.hadoop.HadoopOutputFormat"
  }
}