# ==============================================================================
# コンピュート（EC2インスタンス）
# ==============================================================================

# ------------------------------------------------------------------------------
# AMI（Amazon Linux 2023 の最新版を自動取得）
# ------------------------------------------------------------------------------
# ハードコードせずdata sourceで取得することで、常に最新のAMIが使える。
# AMI IDはリージョンごとに異なるため、変数で管理するよりdata sourceが適切。
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# パブリックEC2（踏み台 兼 検証用）
# ------------------------------------------------------------------------------
resource "aws_instance" "public" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_ec2.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_access.name

  tags = {
    Name = "${local.project}-public-ec2"
  }
}

# ------------------------------------------------------------------------------
# プライベートEC2（VPCエンドポイント検証用）
# ------------------------------------------------------------------------------
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_ec2.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_access.name

  tags = {
    Name = "${local.project}-private-ec2"
  }
}
