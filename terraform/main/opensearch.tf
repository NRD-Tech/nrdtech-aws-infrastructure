# # OpenSearch Domain
# resource "aws_opensearch_domain" "mydata" {
#   domain_name    = "mydata-domain-${var.environment}"
#   engine_version = "OpenSearch_2.17" # Adjust version as needed

#   # Cluster Configuration
#   cluster_config {
#     instance_type          = var.environment == "prod" ? "r6gd.large.search" : "t3.small.search"
#     instance_count         = var.environment == "prod" ? 2 : 2 # NOTE: we must have an even number of data nodes
#     dedicated_master_enabled = var.environment == "prod" ? true : false
#     dedicated_master_type  = var.environment == "prod" ? "m6g.large.search" : null
#     dedicated_master_count = var.environment == "prod" ? 3 : 0  # NOTE: when dedicated_master_enabled = true you must have at least 3 masters
#     zone_awareness_enabled = true # Multi-AZ deployment. This defaults to 2 so we need exactly two subnets
#   }

#   # Storage Configuration
#   # NOTE: This r6gd instances because they have their own dedicated local NVMe SSD storage 118GB per node
#   ebs_options {
#     ebs_enabled = true
#     volume_size = var.environment == "prod" ? 100 : 10
#     volume_type = "gp2" # General Purpose SSD
#   }

#   vpc_options {
#     subnet_ids         = [data.aws_subnets.private.ids[0], data.aws_subnets.private.ids[1]]
#     security_group_ids = [aws_security_group.opensearch_sg.id]
#   }

#   # Snapshot Options
#   snapshot_options {
#     automated_snapshot_start_hour = 0 # Daily snapshot at midnight UTC
#   }

#   # Advanced Options
#   advanced_options = {
#     "rest.action.multi.allow_explicit_index" = "true"
#   }
# }

# # Security Group for OpenSearch
# resource "aws_security_group" "opensearch_sg" {
#   name        = "opensearch_sg-${var.environment}"
#   description = "Security group for OpenSearch domain"
#   vpc_id      = data.aws_vpc.selected.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Output OpenSearch Endpoint
# output "opensearch_endpoint" {
#   value = aws_opensearch_domain.mydata.endpoint
# }
