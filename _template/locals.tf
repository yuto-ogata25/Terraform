# locals.tf
locals {
  # リソース名のprefixを統一する
  # 例："dev-project"
  name_prefix = "${var.env}-${var.project}"

  # 環境ごとの設定を自動で切り替える
  # prodなら削除保護ON・スナップショット取得
  # devなら削除保護OFF・スナップショット取得スキップ
  is_prod             = var.env == "prod"
  deletion_protection = local.is_prod
  skip_final_snapshot = !local.is_prod
}