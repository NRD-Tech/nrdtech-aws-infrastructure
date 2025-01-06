variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "app_ident" {
  type = string
}

variable "ecs_ec2_cpu_architecture" {
  type = string
  description = "ARM64 or X86_64"
}
