# variables.tf
variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS CLIプロファイル名"
  type        = string
  default     = "default"
}

variable "env" {
  description = "環境名（dev/prod）"
  type        = string
}

variable "project" {
  description = "プロジェクト名（リソース名のprefixに使う）"
  type        = string
}

variable "my_ip" {
  description = "自分のグローバルIP（SSH接続許可用）"
  type        = string
}

variable "key_name" {
  description = "EC2キーペア名（AWSコンソールで事前に作成しておく）"
  type        = string
}