###############################################################################
# IAM (Data)
###############################################################################
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

###############################################################################
# IAM User (MCP-Managed)
###############################################################################
resource "aws_iam_user" "mcp-managed" {
  name = "${local.prefix_name}-mcp-managed"
}

resource "aws_iam_user_policy_attachment" "mcp-managed" {
  user       = aws_iam_user.mcp-managed.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_user_policy" "mcp-managed" {
  name = "${local.prefix_name}-mcp-managed-policy"
  user = aws_iam_user.mcp-managed.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ]
        Resource = [
          module.lambda_bastion_ec2_controller.arn,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:ListTags",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "mcp-managed" {
  user = aws_iam_user.mcp-managed.name
}

###############################################################################
# IAM (Lambda Bastion EC2 Controller)
###############################################################################
resource "aws_iam_role" "lambda_bastion_ec2_controller" {
  name               = "${local.prefix_name}-lambda-bastion-ec2-controller"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_bastion_ec2_controller" {
  role       = aws_iam_role.lambda_bastion_ec2_controller.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_bastion_ec2_controller" {
  name = "${local.prefix_name}-lambda-bastion-ec2-controller-policy"
  role = aws_iam_role.lambda_bastion_ec2_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:StartInstances",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/${local.managed_tags.bastion-ec2-controller.Key}" = local.managed_tags.bastion-ec2-controller.Value
          }
        }
      }
    ]
  })
}