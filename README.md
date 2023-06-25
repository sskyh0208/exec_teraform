# deploy

1. envを作成する
   下記コマンドで作成したのち、.env内のAWS認証情報を埋める
   ```bash
   cp .env.example dockerfile/terraform.env
   ```
1. コンテナ起動
   ```bash
   docker compose up -d && docker compose exec terraform bash
   ```
1. データソース用s3バケット作成 ※初回のみ
   ```bash
   APP_NAME=test
   . ./bin/init.sh $APP_NAME
   ```
1. 環境別リソースのデプロイ
   ```bash
   APP_NAME=test
   ENV=dev
   . ./bin/deploy.sh $APP_NAME $ENV