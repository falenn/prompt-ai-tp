provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "./modules/s3"
  aws_account_id = var.aws_account_id
  environment = "prod"
}

module "glue" {
  source = "./modules/glue"
  bronze_bucket = module.s3.bronze_bucket
  silver_bucket = module.s3.silver_bucket
  gold_bucket = module.s3.gold_bucket
  metrics_bucket = module.s3.metrics_bucket
  aws_account_id = var.aws_account_id
}

module "athena" {
  source = "./modules/athena"
  silver_bucket = module.s3.silver_bucket
  gold_bucket = module.s3.gold_bucket
  metrics_bucket = module.s3.metrics_bucket
}