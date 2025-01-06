variable "aws_region" {
  type = string
}

variable "app_ident" {
  description = "Identifier of the application"
  type        = string
}

variable "app_ident_without_env" {
    description = "Identifier of the application that doesn't include the environment"
    type = string
}

variable "environment" {
  type        = string
}

variable "ecs_ec2_cpu_architecture" {
  type = string
  description = "ARM64 or X86_64"
}
