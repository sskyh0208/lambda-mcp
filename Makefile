build:
	docker compose build
rebuild:
	docker compose up -d --build
up:
	docker compose up -d
down:
	docker compose down
delete:
	docker compose down --rmi all --volumes --remove-orphans
logs:
	docker compose logs -f
ls:
	docker compose ls

############################################
# 以下、コンテナに入るコマンド
############################################
terraform:
	docker compose exec aws-lambda-mcp-terraform bash

############################################
# 以下、terraformコマンド
############################################
init:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments init -backend-config="backend.hcl"
plan:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments plan
apply:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments apply
refresh:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments refresh
destroy:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments destroy
fmt:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments fmt
output:
	docker compose exec aws-lambda-mcp-terraform terraform -chdir=./environments output -json