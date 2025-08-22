variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "role_name" {
  description = "Nombre del rol a crear o reutilizar"
  type        = string
}

variable "repo_names" {
  description = "Lista de repos autorizados"
  type        = list(string)
}

variable "actions" {
  description = "Acciones dinámicas para la política"
  type        = list(string)
}
