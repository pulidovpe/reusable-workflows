output "oidc_provider_arn" {
  description = "ARN del OIDC Provider de GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_role_arn" {
  description = "ARN del rol compartido para GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}
