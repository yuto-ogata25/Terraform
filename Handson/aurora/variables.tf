variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

# パスワードはデフォルト値を設定せず対話形式で入力する
# パスワードをハードコードしない
variable "db_password" {
  type      = string
  sensitive = true
}

# BastionホストへのSSH接続を自分のIPのみに制限する

variable "myip" {
  type = string
}
