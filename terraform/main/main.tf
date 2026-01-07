terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
  }
}

provider "aws" {
  region  = var.AWS_REGION
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

module "prod_resources" {
  source = "./prod"
  count  = var.ENVIRONMENT == "prod" ? 1 : 0
  vpc_id = data.aws_vpc.selected.id
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids = data.aws_subnets.public.ids
  app_ident = var.APP_IDENT
  ecs_ec2_cpu_architecture = var.ECS_EC2_CPU_ARCHITECTURE

  providers = {
    aws         = aws        # Default provider
    aws.useast1 = aws.useast1 # Aliased provider
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#############################
# VPC
#############################

# CUSTOM VPC
locals {
  vpc_name = "mycompany-standard-vpc"
}
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

# DEFAULT VPC
# data "aws_vpc" "selected" {
#   default = true
# }

data "aws_subnets" "all" {
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
