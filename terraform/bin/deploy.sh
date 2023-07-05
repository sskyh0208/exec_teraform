#!/bin/bash

APP_NAME=$1
ENV=$2

if [ -z $ENV ] || [ "$ENV" != "dev" ] && [ "$ENV" != "stg" ] && [ "$ENV" != "prod" ]; then
    echo Invalid env.
    return 0
fi

EXEC_DIRNAME=$(dirname $0)

cd $EXEC_DIRNAME

# デプロイ環境ディレクトリ
DEPLOY_DIR=./env/$ENV

# アカウントID取得
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# backend設定ファイルの作成
TEMPLATE_PATH=./bin/template.tfbackend
BACKEND_CONFIG_FILE_PATH=$DEPLOY_DIR/env.tfbackend
export DATA_SOURCE_BUCKET_NAME="$APP_NAME-datasource-$ACCOUNT_ID"
export ENV=$ENV
envsubst '$$DATA_SOURCE_BUCKET_NAME,$$AWS_DEFAULT_REGION,$$ENV' < $TEMPLATE_PATH > $BACKEND_CONFIG_FILE_PATH

cd $DEPLOY_DIR

# terraformの実行
terraform init --reconfigure -backend-config=env.tfbackend

terraform apply -auto-approve -var 'app_name='${APP_NAME}

cd $EXEC_DIRNAME