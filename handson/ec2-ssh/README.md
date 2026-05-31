# 概要

ローカルPCからEC2インスタンスにSSH接続するだけの最小構成。

## 構成図

```
local PC
    ↓SSH(port:22)
Internet
    ↓   
IGW
    ↓
VPC(10.0.0.0/16)
    └─public subnet(10.0.1.0/24)
        └─EC2(Amazon Linux 2023 / t3.micro)

```



## 前提条件

- Terraform (v1.0以上)がインストールされていること
- AWS CLI がインストールされていること
- EC2キーペアを事前に作成していること

## 使い方

### 1. 変数ファイルを準備

1.下記コマンドを実行する
```bash
cp terraform.tfvars.example terraform.tfvars
```
2.「terraform.tfvars」内の変数を変更する

### 2. 環境構築

1.下記コマンドを実行する
```bash
terraform init
terraform plan
terraform apply
```

### 3. 動作確認

1.下記コマンドを実行する
```bash
# パブリックEC2にSSH
ssh -i ~/.ssh/your-key.pem ec2-user@<public_ec2_public_ip>
```

2.下記表示がされ、SSH接続できることを確認する

```bash
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
```

### 4. 事後作業

1. 下記コマンドを実行する
```bash
terraform destroy
```