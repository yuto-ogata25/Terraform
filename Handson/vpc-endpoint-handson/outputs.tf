# ==============================================================================
# 出力値
# ==============================================================================
# apply後にターミナルに表示される値。接続に必要な情報をまとめる。

output "public_ec2_public_ip" {
  description = "パブリックEC2のパブリックIP（SSHの宛先）"
  value       = aws_instance.public.public_ip
}

output "private_ec2_private_ip" {
  description = "プライベートEC2のプライベートIP（踏み台からSSHする宛先）"
  value       = aws_instance.private.private_ip
}

output "ssh_command_step1" {
  description = "Step 1: パブリックEC2にSSH接続するコマンド"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.public.public_ip}"
}

output "ssh_command_step2" {
  description = "Step 2: パブリックEC2からプライベートEC2にSSH接続するコマンド"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.private.private_ip}"
}

output "s3_test_command" {
  description = "S3アクセステストコマンド（各EC2上で実行）"
  value       = "aws s3 ls --region ${var.region}"
}

output "vpc_endpoint_status" {
  description = "VPCエンドポイントの状態"
  value       = var.create_endpoint ? "作成済み（S3アクセス可能）" : "未作成（プライベートEC2からS3タイムアウト）"
}
