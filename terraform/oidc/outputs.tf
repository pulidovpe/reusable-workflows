output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_roles_arn" {
  value = {
    for repo, role in aws_iam_role.github_actions_roles : repo => role.arn
  }
}
