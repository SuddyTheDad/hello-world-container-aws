terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "s3-hwc-aws-tfstate"
    key            = "hwc-aws.terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "ddb-hwc-aws-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
