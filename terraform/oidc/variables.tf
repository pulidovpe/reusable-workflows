variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "role_name_prefix" {
  type        = string
  default     = "oidc-github-actions-role"
}

variable "repo_names" {
  type        = list(string)
  description = "Lista de repos permitidos"
}

variable "oidc_actions" {
  type        = string
  description = "Acciones permitidas para OIDC en GitHub (branch, tag, etc.)"
  default     = "*" # Puede ser "ref:refs/heads/main" si lo quieres restringir
}

variable "policy_actions" {
  type        = list(string)
  description = "Lista de acciones AWS que la política debe permitir"
  default     = ["s3:*", "ec2:*"]
}
