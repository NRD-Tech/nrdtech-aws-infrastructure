resource "aws_ecs_cluster" "ecs_cluster_fargate_1" {
  name = "${var.app_ident}-fargate-ecs-cluster-1"

  setting {
    name  = "containerInsights"
    value = "enabled" # enabled or enhanced
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster_fargate_1.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 0
  }
}

output "ecs_cluster_fargate_1" {
  value = aws_ecs_cluster.ecs_cluster_fargate_1.id
}
