# VPC Endpoint ハンズオン環境（Terraform）

プライベートサブネットからS3へのアクセスを、VPCエンドポイント（ゲートウェイ型）で実現する検証環境です。

## 構成図

```
┌─────────────────────────────────────────────────┐
│ VPC (10.0.0.0/16)                               │
│                                                  │
│  ┌──────────────────┐  ┌──────────────────┐      │
│  │ Public Subnet    │  │ Private Subnet   │      │
│  │ (10.0.1.0/24)    │  │ (10.0.2.0/24)    │      │
│  │                  │  │                  │      │
│  │  ┌────────────┐  │  │  ┌────────────┐  │      │
│  │  │ EC2        │  │  │  │ EC2        │  │      │
│  │  │ (public)   │──┼──┼─▶│ (private)  │  │      │
│  │  └────────────┘  │  │  └─────┬──────┘  │      │
│  └────────┬─────────┘  └────────┼─────────┘      │
│           │                     │                │
│  ┌────────▼─────────┐  ┌───────▼──────────┐      │
│  │ Internet Gateway │  │ VPC Endpoint (S3)│      │
│  └────────┬─────────┘  │ ※後から作成      │      │
│           │            └───────┬──────────┘      │
└───────────┼────────────────────┼──────────────────┘
            │                    │
            ▼                    ▼
        Internet              S3
```

## 前提条件

- Terraform >= 1.5.0
- AWS CLI 設定済み
- EC2キーペアを事前に作成済み

## 使い方

### 1. 変数ファイルを準備

```bash
cp terraform.tfvars.example terraform.tfvars
# 自分の値に書き換える（my_ip, key_name）
```

### 2. 環境構築（VPCエンドポイントなし）

```bash
terraform init
terraform plan
terraform apply
```

### 3. 検証（失敗を確認）

```bash
# パブリックEC2にSSH
ssh -i ~/.ssh/your-key.pem ec2-user@<public_ec2_public_ip>

# パブリックEC2で S3アクセス → 成功
aws s3 ls --region ap-northeast-1

# プライベートEC2にSSH（踏み台経由）
# ※秘密鍵をパブリックEC2にscpするか、ssh-agentを使う
ssh -i ~/.ssh/your-key.pem ec2-user@<private_ec2_private_ip>

# プライベートEC2で S3アクセス → タイムアウト！
aws s3 ls --region ap-northeast-1
```

### 4. VPCエンドポイント作成

```bash
# terraform.tfvars の create_endpoint を true に変更
# create_endpoint = true

terraform apply
```

### 5. 検証（成功を確認）

```bash
# プライベートEC2で再度実行 → 成功！
aws s3 ls --region ap-northeast-1
```

### 6. 環境削除（コスト節約）

```bash
terraform destroy
```

## ファイル構成

| ファイル | 内容 |
|---|---|
| main.tf | provider設定、terraform設定 |
| variables.tf | 変数定義 |
| locals.tf | ローカル変数 |
| network.tf | VPC / サブネット / IGW / ルートテーブル |
| security_group.tf | セキュリティグループ（新スタイル） |
| iam.tf | IAMロール / インスタンスプロファイル |
| compute.tf | EC2インスタンス |
| endpoint.tf | VPCエンドポイント（ゲートウェイ型） |
| outputs.tf | 出力値 |

## Terraformスタイルガイド

このプロジェクトでは以下のスタイルに従っています:

- **セキュリティグループルール**: `aws_vpc_security_group_ingress_rule` / `egress_rule` を使用（[参考](https://dev.classmethod.jp/articles/terraform-security-group/)）
- **ルート定義**: `aws_route` リソースとして分離（`aws_route_table` 内インライン定義は使わない）
- **AMI取得**: data source で最新AMIを動的取得（ハードコードしない）
- **IAMポリシー**: `aws_iam_policy_document` data source を使用（JSONべた書きしない）
- **命名規則**: リソースが1つの場合は `this` を使用（[参考](https://dev.classmethod.jp/articles/terraform-bset-practice-jp/)）
- **タグ付け**: provider の `default_tags` で共通タグを一括設定

## 参考記事

- [TerraformでAWSのセキュリティグループのルールを作成する方法の比較と注意点 | DevelopersIO](https://dev.classmethod.jp/articles/terraform-security-group/)
- [Terraform ベストプラクティスを整理してみました。 | DevelopersIO](https://dev.classmethod.jp/articles/terraform-bset-practice-jp/)
- [Terraform による簡易検証環境テンプレートの紹介 | DevelopersIO](https://dev.classmethod.jp/articles/krsk-terraform-simple-validation-environment-setup-20250731/)
