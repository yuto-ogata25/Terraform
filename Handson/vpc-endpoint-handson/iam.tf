# ==============================================================================
# IAM（EC2からS3にアクセスするためのロール）
# ==============================================================================
# EC2インスタンスに「aws s3 ls」を実行する権限を与える。
# IAMロールはEC2にとっての「身分証明書」。
# これがないとAWS CLIコマンドがアクセス拒否になる。

# ------------------------------------------------------------------------------
# IAMロール（EC2が引き受けるロール）
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_s3_access" {
  name               = "${local.project}-ec2-s3-access-role"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${local.project}-ec2-s3-access-role"
  }
}

# S3読み取り権限をアタッチ（AmazonS3ReadOnlyAccess）
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# ------------------------------------------------------------------------------
# インスタンスプロファイル（EC2にIAMロールを紐づけるための「容器」）
# ------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "${local.project}-ec2-s3-access-profile"
  role = aws_iam_role.ec2_s3_access.name
}
