variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "role_name_prefix" {
  description = "Prefijo del rol"
  type        = string
  default     = "reusable-workflows-role"
}

variable "repo_names" {
  type        = list(string)
  description = "Lista de repos autorizados"
}

variable "oidc_actions" {
  type = list(string)
  description = "Patrón de OIDC (e.g. ref:refs/heads/main)"
}

variable "policy_actions" {
  description = "Acciones por repo"
  type        = map(list(string))
}
