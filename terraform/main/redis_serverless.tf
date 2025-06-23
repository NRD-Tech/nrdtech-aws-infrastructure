# resource "aws_elasticache_serverless_cache" "redis_1" {
#   engine = "valkey"
#   major_engine_version = "7"
#   name   = "${var.app_ident}-redis-1"
#   cache_usage_limits {
#     data_storage {
#       maximum = var.environment == "prod" ? 100 : 10
#       unit    = "GB"
#     }
#     ecpu_per_second {
#       maximum = var.environment == "prod" ? 10000 : 1000
#     }
#   }

#   security_group_ids = [aws_security_group.redis_sg_1.id]
#   subnet_ids         = slice(data.aws_subnets.private.ids, 0, 3)
# }

# resource "aws_security_group" "redis_sg_1" {
#   name   = "${var.app_ident}-redis-sg-1"
#   vpc_id = data.aws_vpc.selected.id

#   ingress {
#     from_port   = 6379
#     to_port     = 6379
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# output "redis_host_1" {
#   value = aws_elasticache_serverless_cache.redis_1.endpoint[0].address
# }

# output "redis_port_1" {
#   value = aws_elasticache_serverless_cache.redis_1.endpoint[0].port
# }

# output "redis_sg_id_1" {
#   value = aws_security_group.redis_sg_1.id
# }
