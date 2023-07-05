locals {
    name_prefix = "${var.env}-${var.app_name}"
}

#------------------------
# data
#------------------------
data "aws_iam_policy" "aws_lambda_basic_execution_role" {
    arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_s3_object" "lambda_function_archive" {
    depends_on = [ null_resource.deploy_lambda_function ]
    bucket = var.s3_lambda_deploy
    key = "lambda_function.py.zip"
}

data "aws_s3_object" "lambda_function_archive_hash" {
  depends_on = [ null_resource.deploy_lambda_function ]

  bucket = var.s3_lambda_deploy
  key = "lambda_function.py.zip.base64sha256.txt"
}

#------------------------
# deploy
#------------------------
resource "null_resource" "deploy_lambda_function" {
    # Lambda関数コードが変更された場合に実行される
    triggers = {
        "code_diff" = filebase64("${path.module}/lambda/lambda_function.py")
    }

    # ディレクトリ階層を無視(-j)して関数コードをzipアーカイブする
    provisioner "local-exec" {
        command = "zip -j ${path.module}/lambda_function.py.zip ${path.module}/lambda/lambda_function.py"
    }

    # デプロイ用のS3バケットにzipアーカイブした関数コードをアップロードする
    provisioner "local-exec" {
        command = "aws s3 cp ${path.module}/lambda_function.py.zip s3://${var.s3_lambda_deploy}/lambda_function.py.zip"
    }

    # zipアーカイブした関数コードのhashを取得してファイルに書き込む
    provisioner "local-exec" {
        command = "openssl dgst -sha256 -binary ${path.module}/lambda_function.py.zip | openssl enc -base64 | tr -d \"\n\" > ${path.module}/lambda_function.py.zip.base64sha256"
    }

    # hash値を書き込んだファイルをデプロイ用のS3バケットにアップロードする
    provisioner "local-exec" {
        command = "aws s3 cp ${path.module}/lambda_function.py.zip.base64sha256 s3://${var.s3_lambda_deploy}/lambda_function.py.zip.base64sha256.txt --content-type \"text/plain\""
    }
}

#----------
# Lambda function
#----------

resource "aws_lambda_function" "function" {
  function_name = "${local.name_prefix}-function"
  description   = ""

  role          = var.role_lambda_arn
  architectures = [ "x86_64" ]
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  s3_bucket        = var.s3_lambda_deploy
  s3_key           = data.aws_s3_object.lambda_function_archive.key
  source_code_hash = data.aws_s3_object.lambda_function_archive_hash.body

  memory_size = 256
  timeout     = 3
}