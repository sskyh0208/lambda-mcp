locals {
    function_name           = var.name
    key                     = "${local.function_name}.zip"
    key_hash                = "${local.function_name}.zip.base64sha256"
    base_dir                = var.function_path
    archive_dir             = ".archive"
    prefix_name             = "${var.product_name}-${var.env_name}"
    s3_archive_key          = "lambda/${local.key}"
    s3_archive_key_hash     = "lambda/${local.key_hash}.txt"
}

###############################################################################
# Data
###############################################################################
data "aws_s3_object" "archive_this" {
    depends_on = [ null_resource.deploy_this ]
    bucket     = var.s3_bucket
    key        = local.s3_archive_key
}

data "aws_s3_object" "archive_this_hash" {
  depends_on = [ null_resource.deploy_this ]
  bucket     = var.s3_bucket
  key        = local.s3_archive_key_hash
}

###############################################################################
# Deploy
###############################################################################
resource "null_resource" "deploy_this" {
  # Lambda関数コードが変更された場合に実行される
  triggers = {
    code_diff = sha1(join("", [
      for f in fileset(local.base_dir, "**/*") : 
      filebase64("${local.base_dir}/${f}")
      if !endswith(f, ".pyc") && !contains(["__pycache__", ".git"], split("/", f)[0])
    ]))
  }

  # アーカイブ用ディレクトリの作成
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "mkdir -p ${local.archive_dir} && cp -r * ${local.archive_dir}"
  }

  # pipインストール
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "pip install -r ${local.archive_dir}/requirements.txt -t ${local.archive_dir}"
  }
  
  # ディレクトリ階層を無視して関数コードをzipアーカイブする
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "cd ${local.archive_dir} && zip -r ${local.key} *"
  }

  # デプロイ用のS3バケットにzipアーカイブした関数コードをアップロードする
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "aws s3 cp --profile ${var.env_name} ${local.archive_dir}/${local.key} s3://${var.s3_bucket}/${local.s3_archive_key}"
  }

  # zipアーカイブした関数コードのhashを取得してファイルに書き込む
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "openssl dgst -sha256 -binary ${local.archive_dir}/${local.key} | openssl enc -base64 | tr -d \"\n\" > ${local.archive_dir}/${local.key_hash}"
  }

  # hash値を書き込んだファイルをデプロイ用のS3バケットにアップロードする
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "aws s3 cp --profile ${var.env_name} ${local.archive_dir}/${local.key_hash} s3://${var.s3_bucket}/${local.s3_archive_key_hash} --content-type \"text/plain\""
  }

  # アーカイブ用ディレクトリの削除
  provisioner "local-exec" {
    working_dir = local.base_dir
    command = "rm -rf ${local.archive_dir}"
  }
}

###############################################################################
# Lambda Function
###############################################################################
resource "aws_lambda_function" "this" {
  function_name      = "${local.prefix_name}-${local.function_name}"
  description        = var.description
  role               = var.role_arn
  architectures      = [ var.architecture ]
  runtime            = var.runtime
  handler            = var.handler
  s3_bucket          = var.s3_bucket
  s3_key             = data.aws_s3_object.archive_this.key
  source_code_hash   = data.aws_s3_object.archive_this_hash.body
  memory_size        = var.memory_size
  timeout            = var.timeout
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  environment {
    variables = var.environment_variables
  }
  
  tags = var.tags
}