output "role_arn" {
  value = try(data.aws_iam_role.existing_role.arn, aws_iam_role.github_actions_role[0].arn)
}

output "oidc_provider_arn" {
  value = try(data.aws_iam_openid_connect_provider.github.arn, aws_iam_openid_connect_provider.github[0].arn)
}
