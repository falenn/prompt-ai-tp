resource "aws_s3_bucket" "bronze" {
  bucket = "${var.aws_account_id}-iot-bronze"
  tags = { Environment = var.environment }
}

resource "aws_s3_bucket" "silver" {
  bucket = "${var.aws_account_id}-iot-silver"
  tags = { Environment = var.environment }
}

resource "aws_s3_bucket" "gold" {
  bucket = "${var.aws_account_id}-iot-gold"
  tags = { Environment = var.environment }
}

resource "aws_s3_bucket" "metrics" {
  bucket = "${var.aws_account_id}-iot-metrics"
  tags = { Environment = var.environment }
}