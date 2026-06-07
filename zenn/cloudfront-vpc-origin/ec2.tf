# ec2.tf

# --- SSM接続用のIAMロール（キーペアレスでEC2に入る用。任意） ---
resource "aws_iam_role" "ec2" {
  name = "${local.prefix}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "${local.prefix}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

# --- EC2用セキュリティグループ（Before：CloudFrontのマネージドプレフィックスリストからのみ許可） ---
resource "aws_security_group" "ec2" {
  name   = "${local.prefix}-web-sg"
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-web-sg"
  }
}

# CloudFront の AWSマネージドプレフィックスリストを取得
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# インバウンド：CloudFront からの HTTP のみ許可
resource "aws_vpc_security_group_ingress_rule" "from_cloudfront" {
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- Webサーバ（Nginxをユーザーデータで起動） ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  # 起動時にNginxをインストール・起動し、index.htmlを置く。
  # systemctl start まで仕込むことで「起動忘れで繋がらない」を防ぐ。
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>handson-dev web origin</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = {
    Name = "${local.prefix}-web01"
  }
}
