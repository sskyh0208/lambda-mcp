output "mcp_managed_access_key_id" {
  value = aws_iam_access_key.mcp-managed.id
}

output "mcp_managed_secret_access_key" {
  value     = aws_iam_access_key.mcp-managed.secret
  sensitive = true
}