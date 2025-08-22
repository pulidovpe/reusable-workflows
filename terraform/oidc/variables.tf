variable "aws_account_id" {
  description = "ID de la cuenta AWS donde se configurará el OIDC y el rol"
  type        = string
}

variable "aws_region" {
  description = "Región AWS donde se desplegarán los recursos"
  type        = string
}

variable "role_name" {
  description = "Nombre del IAM Role a crear o actualizar"
  type        = string
}

variable "repo_names" {
  description = "Lista de repos autorizados a asumir el rol vía OIDC"
  type        = list(string)
}

variable "actions" {
  description = "Lista de permisos de AWS permitidos en la policy"
  type        = list(string)
}
