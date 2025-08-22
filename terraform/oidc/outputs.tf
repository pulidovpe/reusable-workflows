output "oidc_provider_arn" {
  value = try(
    data.aws_iam_openid_connect_provider.github.arn,
    aws_iam_openid_connect_provider.github[0].arn
  )
}

output "github_role_arn" {
  value = { for repo, role in aws_iam_role.github_actions_roles : repo => role.arn }
}

