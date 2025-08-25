variable "aws_region" {
  description = "AWS region"
  type        = string
}

# 🔧 Un rol compartido (nuevo input). Si ya existe, lo importamos en el workflow.
variable "role_name" {
  description = "Nombre del rol IAM compartido para todos los repos"
  type        = string
  default     = "workflows-role-shared"
}

# Repos autorizados (owner/repo)
variable "repo_names" {
  description = "Lista de repositorios (owner/repo) que podrán asumir el rol"
  type        = list(string)
}

# Acciones del OIDC (sufijo del sub). Normalmente sólo "*".
variable "oidc_actions" {
  description = "Lista de acciones permitidas para el sub del OIDC (por repo)"
  type        = list(string)
  default     = ["*"]
}

# Mapa repo -> lista de acciones IAM para su política administrada
variable "policy_actions" {
  description = "Mapa repo -> lista de acciones IAM a permitir en la política de ese repo"
  type        = map(list(string))
}

