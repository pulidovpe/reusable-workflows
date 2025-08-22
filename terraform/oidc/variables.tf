variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "role_name_prefix" {
  type        = string
  description = "Prefijo para los roles IAM"
}

variable "repo_names" {
  type        = list(string)
  description = "Lista de repos autorizados"
}

variable "oidc_actions" {
  type        = string
  default     = "*"
  description = "Patrón de OIDC (e.g. ref:refs/heads/main)"
}

variable "policy_actions" {
  type        = list(string)
  default     = ["ec2:*"]
  description = "Acciones permitidas en la política IAM"
}
