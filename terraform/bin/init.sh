#!/bin/bash

APP_NAME=$1

# アカウントID取得
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# ベースとなるS3の作成
DATA_SOURCE_BUCKET_NAME="${APP_NAME}-datasource-${ACCOUNT_ID}"
aws s3 mb s3://$DATA_SOURCE_BUCKET_NAME