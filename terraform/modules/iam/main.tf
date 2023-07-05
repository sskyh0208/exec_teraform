locals {
    name_prefix = "${var.env}-${var.app_name}"
}

# ---------------------------
# IAM
# ---------------------------
resource "aws_iam_role" "lambda" {
    name = "${local.name_prefix}-role-lambda"
    assume_role_policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
    statement {
        actions = [ "sts:AssumeRole" ]
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = [ "lambda.amazonaws.com" ]
        }
    }
}