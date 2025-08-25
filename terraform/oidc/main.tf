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

# 1. Proveedor OIDC (se crea si no existe, pero se importa antes en oidc-setup.yml)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 2. Roles dinámicos por repo
resource "aws_iam_role" "github_actions_role" {
  name = "${var.role_name}-shared"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # una entrada por repo, ej: repo:owner/repo:*
          "token.actions.githubusercontent.com:sub" = [
            for repo in var.repo_names : "repo:${repo}:*"
          ]
        }
      }
    }]
  })
}

# Crear políticas dinámicamente
resource "aws_iam_policy" "github_actions_policies" {
  for_each = var.policy_actions  # <-- mapa { "owner/repo" = ["accion1","accion2", ...] }

  name = "${replace(each.key, "/", "-")}-policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = each.value     # <-- acciones específicas por repo
        Resource = "*"
      }
    ]
  })
}


# Asociar políticas a roles
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  # 🔧 CLAVE: iteramos sobre el mapa de entrada, no sobre el recurso
  for_each   = var.policy_actions

  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policies[each.key].arn
}

