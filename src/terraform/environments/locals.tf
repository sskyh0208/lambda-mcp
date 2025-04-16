locals {
  env_name = "common"
  aws_account_id = data.aws_caller_identity.current.account_id
  prefix_name = "${var.product_name}-${local.env_name}"
  force_destroy = false

  managed_tags = {
    bastion-ec2-controller = {
      Key  = "MCP-Managed"
      Value = "lambda-bastion-ec2-controller"
    }
  }
}