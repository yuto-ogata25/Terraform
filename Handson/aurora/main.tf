provider "aws" {
  region = var.region
}

# Auroraを配置するVPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env}-aurora-vpc"
  }
}

# フェールオーバー検証のため異なるAZにサブネットを3つ配置する
resource "aws_subnet" "az_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.env}-subnet-az-a"
  }
}

resource "aws_subnet" "az_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.env}-subnet-az-c"
  }
}

resource "aws_subnet" "az_d" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.env}-subnet-az-d"
  }
}

# インターネットゲートウェイ
# PublicサブネットからインターネットへのルートはIGW経由にする
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

# Publicサブネット用ルートテーブル
# 0.0.0.0/0をIGWに向けることで外部アクセスを可能にする
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-public-rtb"
  }
}

# ルートテーブルをPublicサブネット（AZ-A）に関連付ける
resource "aws_route_table_association" "public_az_a" {
  subnet_id      = aws_subnet.az_a.id
  route_table_id = aws_route_table.public.id
}

# BastionホストのセキュリティグループはSSHのみ許可する
# CIDRは自分のIPに絞ることでセキュリティを高める
resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id
  name   = "${var.env}-bastion-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-bastion-sg"
  }
}

# BastionホストはPublicサブネット（AZ-A）に配置する
# t3.microで十分（踏み台用途のため最小スペック）
resource "aws_instance" "bastion" {
  ami                         = "ami-0d52744d6551d851e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.az_a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  tags = {
    Name = "${var.env}-bastion"
  }
}

# Auroraにはサブネットグループが必要
# 複数AZのサブネットを指定することでMulti-AZ構成になる
resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-aurora-subnet-group"
  subnet_ids = [aws_subnet.az_a.id, aws_subnet.az_c.id, aws_subnet.az_d.id]
  tags = {
    Name = "${var.env}-aurora-subnet-group"
  }
}

# Auroraクラスター本体
# フェールオーバー検証のためdeletion_protectionはfalseにする
# localsで環境ごとに自動切換え
# prodなら削除保護ON/スナップショット取得
# devなら削除保護OFF/スナップショット取得スキップ
resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.env}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  database_name           = "handson"
  master_username         = "admin"
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = local.skip_final_snapshot
  deletion_protection     = locals.deletion_protection
  tags = {
    Name = "${var.env}-aurora-cluster"
  }
}

# プライマリインスタンス
resource "aws_rds_cluster_instance" "primary" {
  identifier         = "${var.env}-aurora-primary"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}

# AZ-Cのレプリカ
resource "aws_rds_cluster_instance" "replica_c" {
  identifier         = "${var.env}-aurora-replica-c"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}

# AZ-Dのレプリカ
resource "aws_rds_cluster_instance" "replica_d" {
  identifier         = "${var.env}-aurora-replica-d"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}