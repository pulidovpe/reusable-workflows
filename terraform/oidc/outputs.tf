output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.github.arn != "" ?
    data.aws_iam_openid_connect_provider.github.arn :
    aws_iam_openid_connect_provider.github[0].arn
}

output "github_roles_arn" {
  value = { for r, role in aws_iam_role.github_actions_roles : r => role.arn }
}
