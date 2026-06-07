# locals.tf

locals {
  sys = "handson"
  env = "dev"

  # 全リソース共通のプレフィックス（命名規則：{sys}-{env}-{type}）
  prefix = "${local.sys}-${local.env}"
}
