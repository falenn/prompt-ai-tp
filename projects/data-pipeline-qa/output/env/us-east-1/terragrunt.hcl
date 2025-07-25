terraform {
  source = "../../modules"
}

inputs = {
  aws_account_id = "<your_aws_account_id>"
  environment    = "prod"
}