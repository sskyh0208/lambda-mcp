terraform {
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  shared_config_files      = ["/root/.aws/config"]
  shared_credentials_files = ["/root/.aws/credentials"]
  profile                  = local.env_name

  default_tags {
    tags = {
      Product = var.product_name
      Env     = local.env_name
    }
  }
}