# outputs.tf

output "ec2_public_dns" {
  description = "EC2のパブリックDNS（Beforeの直接アクセス確認に使う）"
  value       = aws_instance.web.public_dns
}

output "ec2_instance_id" {
  description = "EC2インスタンスID（マネコンでCloudFrontオリジン設定するときに使う）"
  value       = aws_instance.web.id
}

output "private_subnet_id" {
  description = "プライベートサブネットID（VPCオリジン化でEC2を移す先）"
  value       = aws_subnet.private.id
}
