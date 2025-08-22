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

# 1. Buscar OIDC Provider existente (si ya está creado)
data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

# 2. Crear OIDC Provider solo si no existe
resource "aws_iam_openid_connect_provider" "github" {
  count           = length(data.aws_iam_openid_connect_provider.github.arn) > 0 ? 0 : 1
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# 3. Crear roles dinámicamente para cada repo
resource "aws_iam_role" "github_actions_roles" {
  for_each = toset(var.repo_names)

  name = "${var.role_name_prefix}-${replace(each.value, "/", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn != "" ?
            data.aws_iam_openid_connect_provider.github.arn :
            aws_iam_openid_connect_provider.github[0].arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${each.value}:*"
          }
        }
      }
    ]
  })
}

# 4. Crear políticas dinámicas por repo
resource "aws_iam_role_policy" "github_repo_policies" {
  for_each = aws_iam_role.github_actions_roles

  name = "policy-${each.key}"
  role = each.value.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:*", "s3:*"],
        Resource = "*"
      }
    ]
  })
}
