data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

# module "vpc" {
#     source = "../../modules/vpc"

#     app_name    = var.app_name
#     env         = var.env

#     cidr_block  = "172.16.0.0/16"
#     az_a        = "ap-northeast-1a"
#     az_b        = "ap-northeast-1c"
# }

module "s3" {
    source = "../../modules/s3"

    app_name    = var.app_name
    env         = var.env

    account_id = local.account_id
}

module "iam" {
    source = "../../modules/iam"

    app_name    = var.app_name
    env         = var.env

    account_id = local.account_id
}

module "lambda" {
    source = "../../modules/lambda"

    depends_on = [ 
        module.iam, module.s3
     ]

    app_name    = var.app_name
    env         = var.env

    account_id = local.account_id

    s3_lambda_deploy = module.s3.s3_lambda.bucket
    role_lambda_arn = module.iam.role_lambda.arn
}