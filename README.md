# deploy

1.
1. env.tfbackendを作成
   コピーして値を埋める
   ```bash
   cp ./env.tfbackend.example ./env.tfbackkend
   ```

2. Terraform初期化
    ```bash
    terraform init -reconfigure -backend-config=env.tfbackend
    ```