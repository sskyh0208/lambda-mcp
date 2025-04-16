variable "product_name" {
  type        = string
  description = "プロダクトの名前"
  default     = "lambda-mcp"
}

variable "aws_region" {
  type        = string
  description = "AWSのリージョン"
  default     = "ap-northeast-1"
}