locals {
  # name_prefixは全リソースの命名に使う
  # 環境名をプレフィックスにすることで
  # devとprodのリソースを一目で区別できる
  name_prefix = var.env

  # envがprodのときだけ削除保護をtrueにする
  # tfvarsでenvを指定するだけで自動的に切り替わる
  # 削除保護のことをエンジニアが意識しなくていい設計
  deletion_protection = var.env == "prod" ? true : false

  # prodのみfinal snapshotを取得する
  # devは検証後にすぐ削除できるようskipする
  skip_final_snapshot = var.env == "prod" ? false : true
}