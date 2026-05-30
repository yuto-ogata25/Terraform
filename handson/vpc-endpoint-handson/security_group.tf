# ==============================================================================
# セキュリティグループ
# ==============================================================================
# DevelopersIO推奨スタイル:
#   aws_vpc_security_group_ingress_rule / egress_rule を使用する。
#   旧来の aws_security_group 内インライン定義や aws_security_group_rule は使わない。
#   理由: ルール単位のタグ付け・importが可能になるため。
#   参考: https://dev.classmethod.jp/articles/terraform-security-group/

# ------------------------------------------------------------------------------
# パブリックEC2用セキュリティグループ
# ------------------------------------------------------------------------------
resource "aws_security_group" "public_ec2" {
  vpc_id = aws_vpc.this.id
  name   = "${local.project}-public-ec2-sg"

  tags = {
    Name = "${local.project}-public-ec2-sg"
  }
}

# SSH: 自分のIPからのみ許可
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_ec2.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip

  tags = {
    Name = "SSH from my IP"
  }
}

# アウトバウンド: 全て許可
resource "aws_vpc_security_group_egress_rule" "public_all" {
  security_group_id = aws_security_group.public_ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "Allow all outbound"
  }
}

# ------------------------------------------------------------------------------
# プライベートEC2用セキュリティグループ
# ------------------------------------------------------------------------------
resource "aws_security_group" "private_ec2" {
  vpc_id = aws_vpc.this.id
  name   = "${local.project}-private-ec2-sg"

  tags = {
    Name = "${local.project}-private-ec2-sg"
  }
}

# SSH: パブリックサブネットからのみ許可（踏み台経由）
resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id            = aws_security_group.private_ec2.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.public_ec2.id

  tags = {
    Name = "SSH from public EC2"
  }
}

# アウトバウンド: 全て許可
# ※ VPCエンドポイント経由のS3アクセスにはHTTPS(443)のアウトバウンドが必要
resource "aws_vpc_security_group_egress_rule" "private_all" {
  security_group_id = aws_security_group.private_ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "Allow all outbound"
  }
}
