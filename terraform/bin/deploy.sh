#!/bin/bash

APP_NAME=$1
ENV=$2

EXEC_DIRNAME=$(dirname $0)

cd $EXEC_DIRNAME

# デプロイ環境ディレクトリ
DEPLOY_DIR=./env/$ENV

# アカウントID取得
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# backend設定ファイルの作成
TEMPLATE_PATH=./bin/template.tfbackend
BACKEND_CONFIG_FILE_PATH=$DEPLOY_DIR/env.tfbackend

cp $TEMPLATE_STR $BACKEND_CONFIG_FILE_PATH

export DATA_SOURCE_BUCKET_NAME="$APP_NAME-datasource-$ACCOUNT_ID"
envsubst '$$DATA_SOURCE_BUCKET_NAME,$$ENV' < $BACKEND_CONFIG_FILE_PATH

cd $DEPLOY_DIR

terraform init --reconfigure -backend-config=$BACKEND_CONFIG_FILE_PATH

terraform apply -var 'app_name=${APP_NAME}'

cd $EXEC_DIRNAME