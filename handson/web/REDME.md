今回のハンズオン

variable
```hcl
env = "handson"
my_ip = "対話モードで入力"
```

locals

```hcl
app_name = "web"
name_prefix = "${var.env}-${local.app_name}"
```

vpcとサブネットを作成、その後app nameという変数を定義
variable blockで環境名を定義
localsで二つの変数をまとめて変数の加工
最後にWEBサーバのデプロイ
variable blockの便利さを体験する