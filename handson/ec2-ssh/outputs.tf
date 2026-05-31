# outputs.tf

# よく使うoutputのテンプレート
# 使わないものはコピー後に削除してOK

output "vpc_id" {
  description = "VPC ID"
  value       = null # 実装時に差し替える例：aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "パブリックサブネットIDのリスト"
  value       = null # 実装時に差し替える例：[aws_subnet.public.id]
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = null # 実装時に差し替える例：[aws_subnet.private.id]
}