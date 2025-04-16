variable "product_name" {
  description = "プロダクト名"
  type        = string
}

variable "env_name" {
  description = "環境名"
  type        = string
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
}

variable "aws_account_id" {
  description = "AWSアカウントID"
  type        = string
}

variable "name" {
  description = "Lambda関数名"
  type        = string
}

variable "description" {
  description = "Lambda関数の説明"
  type        = string
}

variable "function_path" {
  description = "Lambda関数のディレクトリパス"
  type        = string
}

variable "role_arn" {
  description = "Lambda関数のIAMロールARN"
  type        = string
}

variable "handler" {
  description = "Lambda関数のハンドラ"
  type        = string
}

variable "runtime" {
  description = "Lambda関数のランタイム"
  type        = string
  default     = "python3.13"
}

variable "memory_size" {
  description = "Lambda関数のメモリサイズ"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Lambda関数のタイムアウト"
  type        = number
  default     = 10
}

variable "ephemeral_storage_size" {
  description = "Lambda関数のephemeral storageのサイズ"
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "Lambda関数の環境変数"
  type        = map(string)
  default     = {}
}

variable "architecture" {
  description = "Lambda関数のアーキテクチャ"
  type        = string
  default     = "x86_64"
}

variable "s3_bucket" {
  description = "Lambda関数のS3バケット"
  type        = string
}

variable "tags" {
  description = "Lambda関数のタグ"
  type        = map(string)
  default     = {}
}