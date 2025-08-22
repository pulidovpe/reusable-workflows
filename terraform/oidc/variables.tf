variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "role_name" {
  type        = string
  description = "Role name for GitHub OIDC"
}

variable "repo_names" {
  type        = list(string)
  description = "List of GitHub repositories allowed to assume the role"
}

variable "actions" {
  type        = list(string)
  description = "AWS actions allowed in the policy"
  default     = ["ec2:*", "s3:*"]
}
