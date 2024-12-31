# locals {
#   database_name = "<your database name>"
#   publicly_accessible = true
# }

# variable "rds_postgres_serverless_master_password" {
#     type = string
# }

# # Create an Aurora DB cluster
# resource "aws_rds_cluster" "aurora_cluster" {
#   cluster_identifier      = "${var.app_ident}-cluster-1"
#   engine                  = "aurora-postgresql"
#   engine_mode             = "provisioned"
#   engine_version          = "16.2"
#   vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
#   database_name           = locals.database_name
#   master_username         = "dbadmin"
#   master_password         = var.rds_postgres_serverless_master_password
#   db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
#   skip_final_snapshot     = false
#   backup_retention_period = var.environment == "prod" ? 5 : 1
#   deletion_protection = true
#   storage_encrypted = true

#   serverlessv2_scaling_configuration {
#     max_capacity = var.environment == "prod" ? 3.0 : 1.0
#     min_capacity = 0.5
#   }
# }

# resource "aws_security_group" "aurora_sg" {
#   name        = "${var.app_ident}-aurora-sg"
#   vpc_id      = data.aws_vpc.selected.id

#   # Inbound rules (note: this is publically accessible so only allow certain ips to access it)
#   ingress {
#     description = "PostgreSQL"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = [
#         data.aws_vpc.selected.cidr_block, # Internally ip's for our VPC
#         # "1.2.3.4/32", # Some Developer's IP
#     ]
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.app_ident}-aurora-sg"
#     Environment = var.environment
#   }
# }

# resource "aws_db_subnet_group" "aurora_subnet_group" {
#   name       = "${var.app_ident}-aurora-subnet-group"
#   subnet_ids = data.aws_subnets.subnets.ids

#   tags = {
#     Name        = "${var.app_ident}-aurora-subnet-group"
#     Environment = var.environment
#   }
# }

# # Create an instance within the cluster
# resource "aws_rds_cluster_instance" "aurora_instance" {
#   identifier         = "${var.app_ident}-instance-1"
#   cluster_identifier = aws_rds_cluster.aurora_cluster.id
#   instance_class     = "db.serverless"
#   engine             = aws_rds_cluster.aurora_cluster.engine
#   engine_version     = aws_rds_cluster.aurora_cluster.engine_version
#   publicly_accessible = locals.publicly_accessible
# }
