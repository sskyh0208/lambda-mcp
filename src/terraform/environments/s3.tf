###############################################################################
# S3 Bucket
###############################################################################
resource "aws_s3_bucket" "lambda_source" {
  bucket        = "${local.prefix_name}-lambda-source-${local.aws_account_id}"
  force_destroy = local.force_destroy
}