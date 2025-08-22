provider "aws" {
  region = var.aws_region
}

# 🔹 Detectar si OIDC Provider ya existe
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 🔹 Crear OIDC Provider si no existe
resource "aws_iam_openid_connect_provider" "github" {
  count            = length(try(data.aws_iam_openid_connect_provider.github.arn, "")) > 0 ? 0 : 1
  url              = "https://token.actions.githubusercontent.com"
  client_id_list   = ["sts.amazonaws.com"]
  thumbprint_list  = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "9e99a48a9960b14926bb7f3b02e22da0ecd4e1c9"
  ]
}

# 🔹 Verificar si el rol ya existe
data "aws_iam_role" "existing_role" {
  name = var.role_name
}

# 🔹 Crear rol solo si no existe
resource "aws_iam_role" "github_actions_role" {
  count = length(try(data.aws_iam_role.existing_role.arn, "")) > 0 ? 0 : 1
  name  = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = try(data.aws_iam_openid_connect_provider.github.arn, "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com")
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for repo in var.repo_names : "repo:${repo}:*"
            ]
          }
        }
      }
    ]
  })
}

# 🔹 Crear o actualizar la política inline
resource "aws_iam_role_policy" "github_policy" {
  name = "github-actions-dynamic-policy"
  role = try(data.aws_iam_role.existing_role.name, var.role_name)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.actions
        Resource = "*"
      }
    ]
  })
}
