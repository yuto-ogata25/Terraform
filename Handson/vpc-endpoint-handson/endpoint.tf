# ==============================================================================
# VPCエンドポイント（ゲートウェイ型 - S3）
# ==============================================================================
# ゲートウェイ型VPCエンドポイントの特徴:
#   - S3とDynamoDBのみ対応
#   - 無料（インターフェース型は有料）
#   - ルートテーブルにプレフィックスリストが自動追加される
#   - セキュリティグループは不要（ルートテーブルベースで制御）
#
# 検証手順:
#   1. 最初は create_endpoint = false で apply → プライベートEC2からS3タイムアウト確認
#   2. create_endpoint = true に変更して apply → プライベートEC2からS3成功確認
# ==============================================================================

variable "create_endpoint" {
  description = "VPCエンドポイントを作成するかどうか（検証の前後で切り替える）"
  type        = bool
  default     = false # 最初はfalse → 検証後にtrueに変更
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_endpoint ? 1 : 0

  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"

  # ゲートウェイ型を明示（デフォルトはGatewayだが明記する）
  vpc_endpoint_type = "Gateway"

  # プライベートサブネットのルートテーブルに紐づける
  # → apply後、ルートテーブルにS3のプレフィックスリスト（pl-xxx）が自動追加される
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${local.project}-s3-endpoint"
  }
}
