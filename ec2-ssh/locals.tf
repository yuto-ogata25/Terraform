# locals.tf
locals {
  # リソース名のprefixを統一する
  # 例："dev-project"
  name_prefix = "${var.env}-${var.project}"
}