# provider.tf
# 土台インフラ（VPC / Subnet / IGW / RouteTable / IAM / SG / EC2）用のプロバイダ。
# CloudFront・ACM・Route53 はマネコンで作るため、us-east-1 プロバイダは不要。

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  # 全リソースに共通タグを自動付与する
  default_tags {
    tags = {
      SystemName = local.sys
      Env        = local.env
      ManagedBy  = "terraform"
      Project    = "cloudfront-vpc-origin"
    }
  }
}
