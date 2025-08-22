variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "repo_names" {
  type        = list(string)
  description = "Lista de repositorios habilitados para usar OIDC"
}

variable "role_name_prefix" {
  type        = string
  default     = "oidc-github-actions-role"
  description = "Prefijo para nombrar roles de OIDC dinámicamente"
}
