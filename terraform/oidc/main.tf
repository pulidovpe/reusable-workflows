terraform {
  backend "s3" {
    bucket         = "devops-aws-backend-tfstate"
    key            = "test/oidc-setup.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Intentar buscar el OIDC Provider existente
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Crear un OIDC Provider solo si no existe
resource "aws_iam_openid_connect_provider" "github" {
  count            = length(data.aws_iam_openid_connect_provider.github.*.arn) == 0 ? 1 : 0
  url              = "https://token.actions.githubusercontent.com"
  client_id_list   = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 3. # Crear un rol por cada repo
resource "aws_iam_role" "github_actions_roles" {
  for_each = toset(var.repo_names)

  name = "${var.role_name_prefix}-${replace(each.value, "/", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = try(
            data.aws_iam_openid_connect_provider.github.arn,
            aws_iam_openid_connect_provider.github[0].arn
          )
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${each.value}:${var.oidc_actions}"
          }
        }
      }
    ]
  })
}

# 4. Crear política personalizada por cada rol
resource "aws_iam_role_policy" "github_policy" {
  for_each = aws_iam_role.github_actions_roles

  name = "oidc-github-actions-role-policy-${replace(each.key, "/", "-")}"
  role = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.policy_actions
        Resource = "*"
      }
    ]
  })
}
