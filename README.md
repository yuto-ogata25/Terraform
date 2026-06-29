# Terraform

AWSインフラを Terraform で構築・検証するリポジトリ。
ハンズオンの写経ではなく、自分で構成を考えて手を動かし、
実際に動作を確認したものだけを置いています。

## このリポジトリでやっていること

- IaC（Infrastructure as Code）で AWS、Azureリソースを再現可能な形で管理
- `terraform plan` で差分を確認 → レビュー → `apply` の流れを徹底
- 検証が終わったら必ず `terraform destroy` で削除し、消し忘れ課金を防ぐ

## 検証済みディレクトリ

- aurora-failover
- cloudfront-vpc-origin
- ec2-ssh

##　検証中・調整中
- azure-snapshot

## AWS用テンプレート
- _template