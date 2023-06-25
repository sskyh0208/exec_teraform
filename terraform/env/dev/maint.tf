module "vpc" {
    source = "../../modules/vpc"

    app_name    = var.app_name
    env         = var.env

    cidr_block  = "172.16.0.0/16"
    az_a        = "ap-northeast-1a"
    az_b        = "ap-northeast-1c"
}