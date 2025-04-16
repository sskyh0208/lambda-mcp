###############################################################################
# Lambda (Chatbot Widget)
###############################################################################
module "lambda_bastion_ec2_controller" {
  source        = "../modules/lambda/zip"
  function_path = "../../lambda/bastion-ec2-controller"

  aws_region     = var.aws_region
  aws_account_id = local.aws_account_id
  product_name   = var.product_name
  env_name       = local.env_name

  name         = "bastion-ec2-controller"
  description  = "踏み台EC2サーバーを起動または停止するLambda関数"
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.13"
  architecture = "arm64"
  memory_size  = 128
  timeout      = 10
  role_arn     = aws_iam_role.lambda_bastion_ec2_controller.arn
  s3_bucket    = aws_s3_bucket.lambda_source.bucket

  environment_variables = {
    TZ                    = "Asia/Tokyo"
    TARGET_TAG_KEY    = local.managed_tags.bastion-ec2-controller.Key
    TARGET_TAG_VALUE           = local.managed_tags.bastion-ec2-controller.Value
  }

  tags = {
    Name        = "${local.prefix_name}-bastion-ec2-controller"
    Environment = local.env_name
    Product     = var.product_name
    ManagedBy   = "lambda-mcp"
  }
}