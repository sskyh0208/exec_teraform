locals {
    name_prefix = "${var.env}-${var.app_name}"
}

# ---------------------------
# S3
# ---------------------------
resource "aws_s3_bucket" "lambda" { 
    bucket = "${local.name_prefix}-lambda-deploy-${var.account_id}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda" {
    bucket = aws_s3_bucket.lambda.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "lambda" {
    bucket = aws_s3_bucket.lambda.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "lambda" {
    bucket = aws_s3_bucket.lambda.id

    rule {
        object_ownership = "BucketOwnerEnforced"
    }
}