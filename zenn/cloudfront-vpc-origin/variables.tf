# variables.tf

variable "web_ami_id" {
  description = "パブリックEC2をAMI化したイメージID（Nginx焼き込み済み）。マネコンで作成したものを指定する。"
  type        = string
  # 例: "ami-0123456789abcdef0"
  # terraform.tfvars に書くか、apply時に -var で渡す
}
