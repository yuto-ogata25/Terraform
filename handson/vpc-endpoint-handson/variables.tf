# ==============================================================================
# 変数定義
# ==============================================================================

variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "パブリックサブネットのCIDRブロック"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "プライベートサブネットのCIDRブロック"
  type        = string
  default     = "10.0.2.0/24"
}

variable "my_ip" {
  description = "SSH接続を許可する自分のグローバルIP（例: 203.0.113.1/32）"
  type        = string
}

variable "key_name" {
  description = "EC2に紐づけるキーペア名（事前にAWSコンソールで作成しておく）"
  type        = string
}

variable "instance_type" {
  description = "EC2のインスタンスタイプ（無料枠: t2.micro）"
  type        = string
  default     = "t2.micro"
}
