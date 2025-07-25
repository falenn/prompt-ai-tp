resource "aws_glue_catalog_database" "iot_db" {
  name = "iot_db"
}

resource "aws_glue_job" "bronze_to_silver" {
  name     = "bronze-to-silver-job"
  role_arn = aws_iam_role.glue_role.arn
  command {
    script_location = "s3://${var.bronze_bucket}/scripts/bronze_to_silver.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${var.bronze_bucket}/temp/"
    "--enable-metrics" = "true"
  }
  glue_version = "4.0"
}

resource "aws_glue_job" "silver_to_gold" {
  name     = "silver-to-gold-job"
  role_arn = aws_iam_role.glue_role.arn
  command {
    script_location = "s3://${var.silver_bucket}/scripts/silver_to_gold.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language" = "python"
    "--TempDir"      = "s3://${var.silver_bucket}/temp/"
    "--enable-metrics" = "true"
  }
  glue_version = "4.0"
}

resource "aws_iam_role" "glue_role" {
  name = "glue-iot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "glue.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "glue_policy" {
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          "arn:aws:s3:::${var.bronze_bucket}/*",
          "arn:aws:s3:::${var.silver_bucket}/*",
          "arn:aws:s3:::${var.gold_bucket}/*",
          "arn:aws:s3:::${var.metrics_bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["glue:*", "logs:*"],
        Resource = "*"
      }
    ]
  })
}