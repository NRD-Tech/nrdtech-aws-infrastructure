variable "AWS_REGION" {
  type = string
}

variable "APP_IDENT" {
  description = "Identifier of the application"
  type        = string
}

variable "APP_IDENT_WITHOUT_ENV" {
    description = "Identifier of the application that doesn't include the environment"
    type = string
}

variable "ENVIRONMENT" {
  type        = string
}

variable "ECS_EC2_CPU_ARCHITECTURE" {
  type = string
  description = "ARM64 or X86_64"
}
