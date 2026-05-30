# ==============================================================================
# ネットワーク（VPC / サブネット / IGW / ルートテーブル）
# ==============================================================================

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true  # VPC内部DNS有効化（VPCエンドポイントの名前解決に必要）
  enable_dns_hostnames = true  # パブリックDNSホスト名の有効化

  tags = {
    Name = "${local.project}-vpc"
  }
}

# ------------------------------------------------------------------------------
# サブネット
# ------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.az
  map_public_ip_on_launch = true # パブリックサブネットなのでパブリックIP自動付与

  tags = {
    Name = "${local.project}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = local.az

  tags = {
    Name = "${local.project}-private-subnet"
  }
}

# ------------------------------------------------------------------------------
# インターネットゲートウェイ
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project}-igw"
  }
}

# ------------------------------------------------------------------------------
# ルートテーブル（パブリック）
# ------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project}-public-rt"
  }
}

# パブリックルートテーブルにインターネットへのルートを追加
# ※ aws_route_table 内のインラインroute定義ではなく、
#   aws_route リソースとして分離する（管理しやすい）
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# ルートテーブル（プライベート）
# ------------------------------------------------------------------------------
# プライベートサブネットにはインターネットへのルートを設定しない。
# これにより、プライベートEC2からS3へのアクセスがタイムアウトすることを検証できる。
# VPCエンドポイント作成後、自動的にこのルートテーブルにプレフィックスリストが追加される。
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
