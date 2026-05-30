# main.tf
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # リモートバックエンド使う時はここを有効化
  # backend "s3" {
  #   bucket = "your-tfstate-bucket"
  #   key    = "your-project/terraform.tfstate"
  #   region = "ap-northeast-1"
  # }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}