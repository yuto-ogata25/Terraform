variable "azure_region" {
  description = "Azureリージョン"
  type        = string
  default     = "japaneast"
}

variable "subscription_id" {
  description = "AzureサブスクリプションID"
  type        = string
}

variable "env" {
  description = "環境名（dev/prod）"
  type        = string
}

variable "project" {
  description = "プロジェクト名"
  type        = string
}

variable "my_ip" {
  description = "自分のグローバルIP（SSH許可用）"
  type        = string
}

variable "admin_username" {
  description = "VMの管理者ユーザー名"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "SSH公開鍵のパス"
  type        = string
}