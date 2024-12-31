terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  default_tags {
    tags = data.terraform_remote_state.app_bootstrap.outputs.app_tags
  }
}

# Sometimes we specifically need us-east-1 for some resources
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
  default_tags {
    tags = data.terraform_remote_state.app_bootstrap.outputs.app_tags
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#############################
# Default VPC
# NOTE: You must configure your subnets to have names that include
#       "private" and "public" so the correct subnets can be identified
#############################
data "aws_vpc" "selected" {
  default = true
}
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

#############################
# Custom VPC
# NOTE: You must configure your subnets to have names that include
#       "private" and "public" so the correct subnets can be identified
#############################
# VPC
# locals {
#   vpc_name = "<my custom vpc name>"
# }
# data "aws_vpc" "selected" {
#   filter {
#     name   = "tag:Name"
#     values = [locals.vpc_name]
#   }
# }
# 
# # Subnets
# data "aws_subnet_ids" "all" {
#   vpc_id = data.aws_vpc.selected.id
# }
# data "aws_subnet_ids" "private" {
#   vpc_id = data.aws_vpc.selected.id
#   tags = {
#     Name = "*private*"
#   }
# }
# data "aws_subnet_ids" "public" {
#   vpc_id = data.aws_vpc.selected.id
#   tags = {
#     Name = "*public*"
#   }
# }
#######################################

module "prod_resources" {
  source = "./prod"
  count  = var.environment == "prod" ? 1 : 0
  vpc_id = data.aws_vpc.selected.id
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids = data.aws_subnets.public.ids
  app_ident = var.app_ident

  providers = {
    aws        = aws        # Default provider
    aws.useast1 = aws.useast1 # Aliased provider
  }
}
