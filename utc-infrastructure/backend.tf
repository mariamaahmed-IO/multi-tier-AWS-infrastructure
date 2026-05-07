terraform {
  backend "s3" {
    bucket         = "utc-terraform-state-dev"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "utc-terraform-locks"
    encrypt        = true
  }
}