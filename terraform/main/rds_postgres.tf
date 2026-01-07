# variable "RDS_MASTER_PASSWORD" {
#   type        = string
#   description = "Master password for RDS PostgreSQL instance"
#   sensitive   = true
# }

# locals {
#   database_name         = "mydb"
#   publicly_accessible  = false
#   subnet_ids           = data.aws_subnets.private.ids
#   skip_final_snapshot  = false
  
#   instance_class = var.ENVIRONMENT == "staging" ? "db.t4g.micro" : "db.t4g.small"
  
#   backup_retention_period = var.ENVIRONMENT == "prod" ? 7 : 1
#   multi_az                = var.ENVIRONMENT == "prod" ? true : false
# }

# resource "aws_db_parameter_group" "postgres_hipaa" {
#   name   = "${var.APP_IDENT}-postgres-hipaa-params"
#   family = "postgres18"
  
#   parameter {
#     name  = "rds.force_ssl"
#     value = "1"
#   }
  
#   parameter {
#     name  = "shared_preload_libraries"
#     value = "pg_stat_statements,pgaudit"
#   }
  
#   parameter {
#     name  = "pgaudit.log"
#     value = "all"
#   }
  
#   parameter {
#     name  = "pgaudit.log_catalog"
#     value = "1"
#   }
  
#   parameter {
#     name  = "pgaudit.log_parameter"
#     value = "1"
#   }
  
#   parameter {
#     name  = "pgaudit.log_statement_once"
#     value = "1"
#   }
  
#   parameter {
#     name  = "pgaudit.role"
#     value = "rds_pgaudit"
#   }
  
#   tags = {
#     Name        = "${var.APP_IDENT}-postgres-hipaa-params"
#     Environment = var.ENVIRONMENT
#   }
# }

# resource "aws_db_instance" "postgres" {
#   identifier     = "${var.APP_IDENT}-postgres"
#   engine         = "postgres"
#   engine_version = "18.1"
#   instance_class = local.instance_class
  
#   allocated_storage     = 20
#   max_allocated_storage = var.ENVIRONMENT == "prod" ? 100 : 50
#   storage_type          = "gp3"
#   storage_encrypted      = true
  
#   db_name  = local.database_name
#   username = "dbadmin"
#   password = var.RDS_MASTER_PASSWORD
  
#   vpc_security_group_ids = [aws_security_group.postgres_sg.id]
#   db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
#   parameter_group_name   = aws_db_parameter_group.postgres_hipaa.name
#   publicly_accessible    = local.publicly_accessible
  
#   backup_retention_period = local.backup_retention_period
#   backup_window          = "03:00-04:00"
#   maintenance_window     = "mon:04:00-mon:05:00"
  
#   multi_az               = local.multi_az
#   auto_minor_version_upgrade = true
  
#   skip_final_snapshot       = local.skip_final_snapshot
#   final_snapshot_identifier = local.skip_final_snapshot ? null : "${var.APP_IDENT}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
#   deletion_protection = var.ENVIRONMENT == "prod" ? true : false
  
#   performance_insights_enabled = var.ENVIRONMENT == "prod" ? true : false
#   performance_insights_retention_period = var.ENVIRONMENT == "prod" ? 7 : null
  
#   monitoring_interval = var.ENVIRONMENT == "prod" ? 60 : 0
#   monitoring_role_arn = var.ENVIRONMENT == "prod" ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  
#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  
#   copy_tags_to_snapshot = true
  
#   tags = {
#     Name        = "${var.APP_IDENT}-postgres"
#     Environment = var.ENVIRONMENT
#   }
# }

# resource "aws_security_group" "postgres_sg" {
#   name        = "${var.APP_IDENT}-postgres-sg"
#   description = "Security group for PostgreSQL RDS instance in private subnet"
#   vpc_id      = data.aws_vpc.selected.id

#   ingress {
#     description = "PostgreSQL from VPC"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = [
#       data.aws_vpc.selected.cidr_block,
#     ]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.APP_IDENT}-postgres-sg"
#     Environment = var.ENVIRONMENT
#   }
# }

# resource "aws_db_subnet_group" "postgres_subnet_group" {
#   name       = "${var.APP_IDENT}-postgres-subnet-group"
#   subnet_ids = local.subnet_ids

#   tags = {
#     Name        = "${var.APP_IDENT}-postgres-subnet-group"
#     Environment = var.ENVIRONMENT
#   }
# }

# output "rds_postgres_endpoint" {
#   value       = aws_db_instance.postgres.endpoint
#   description = "RDS PostgreSQL instance endpoint"
# }

# output "rds_postgres_address" {
#   value       = aws_db_instance.postgres.address
#   description = "RDS PostgreSQL instance address"
# }

# output "rds_postgres_port" {
#   value       = aws_db_instance.postgres.port
#   description = "RDS PostgreSQL instance port"
# }

# resource "aws_iam_role" "rds_enhanced_monitoring" {
#   count = var.ENVIRONMENT == "prod" ? 1 : 0
#   name  = "${var.APP_IDENT}-rds-enhanced-monitoring"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "monitoring.rds.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = {
#     Name        = "${var.APP_IDENT}-rds-enhanced-monitoring"
#     Environment = var.ENVIRONMENT
#   }
# }

# resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
#   count      = var.ENVIRONMENT == "prod" ? 1 : 0
#   role       = aws_iam_role.rds_enhanced_monitoring[0].name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
# }

