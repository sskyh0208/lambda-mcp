# lambda-mcp

このリポジトリは、LambdaをMCPサーバーとして利用するためのものです。

[AWS Lambda MCP Server](https://github.com/awslabs/mcp/tree/main/src/lambda-mcp-server) を使用して、デプロイしたLambdaをMCPサーバーとして利用します。

## 機能

- MCPサーバーとして利用するためのAWS Lambdaをデプロイ
- Terraformによるインフラ管理

## セットアップ手順

### 1. AWSアカウントの設定

1. AWSアカウントにIAMユーザーを作成する
   - 必要な権限: Lambda、EC2、IAM、S3の管理権限
   - アクセスキーIDとシークレットアクセスキーを取得

2. AWS認証情報を設定する
   - `.aws/credentials.example`ファイルをコピーして`.aws/credentials`を作成
   - `default`と`common`プロファイルに認証情報を設定

   ```
   [default]
   aws_access_key_id = あなたのアクセスキーID
   aws_secret_access_key = あなたのシークレットアクセスキー

   [common]
   aws_access_key_id = あなたのアクセスキーID
   aws_secret_access_key = あなたのシークレットアクセスキー
   ```

3. Terraform状態ファイル用のS3バケットを作成する
   - AWSコンソールからS3バケットを作成
   - バケット名をメモしておく

4. 環境設定ファイルを設定する
   - `src/terraform/environments/backend.hcl.example`をコピーして`backend.hcl`を作成
   - 以下のように設定を編集:

   ```
   bucket  = "あなたのS3バケット名"
   key     = "terraform.tfstate"
   region  = "ap-northeast-1"
   profile = "common"
   ```

### 2. インフラストラクチャのデプロイ

1. Dockerコンテナを起動する
   ```
   make up
   ```

2. Terraformを初期化する
   ```
   make init
   ```

3. インフラストラクチャをデプロイする
   ```
   make apply
   ```

4. 出力情報を取得する
   ```
   make output
   ```
   - 出力された認証情報を使い、`lambda-mcp`プロファイルを作成する

### 3. MCPの設定

事前にuvをインストールしておく必要があります。

1. MCPサーバーの設定ファイルに以下の設定を追加する
   ```json
   "awslabs.lambda-mcp-server@latest": {
     "command": "uvx",
     "args": [
       "awslabs.lambda-mcp-server@latest"
     ],
     "env": {
       "AWS_PROFILE": "lambda-mcp",
       "AWS_REGION": "ap-northeast-1",
       "FUNCTION_TAG_KEY": "ManagedBy",
       "FUNCTION_TAG_VALUE": "lambda-mcp"
     }
   }
   ```

2. MCPサーバーを起動する