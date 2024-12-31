# locals {
#   # (Optional) Config for EC2 Capacity
#   # NOTE: You only need these if you are enabling the allocation of EC2 servers to your cluster
#   #       if you don't do that you can still use Fargate
#   ec2_instance_type = "t3.large"
#   ec2_key_name = "<your ssh key name>"
#   subnet_ids = var.private_subnet_ids  # or var.public_subnet_ids
#   min_num_servers = 1
#   max_num_servers = 2
# }

# resource "aws_ecs_cluster" "ecs_cluster_1" {
#   name = "${var.app_ident}-ecs-cluster-1"
# }

# output "ecs_cluster_1" {
#   value = aws_ecs_cluster.ecs_cluster_1.id
# }

# #############################################################################################
# # Enable the below resources if you want EC2 Capacity in addition to Fargate
# #############################################################################################

# resource "aws_autoscaling_group" "ecs_1" {
#   name = "${var.app_ident}-ecs-asg"
#   desired_capacity     = locals.min_num_servers
#   min_size             = locals.min_num_servers
#   max_size             = locals.max_num_servers
#   vpc_zone_identifier  = locals.subnet_ids
#   protect_from_scale_in = false

#   launch_template {
#     id      = aws_launch_template.launch_template_1.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "ECS - ${aws_ecs_cluster.ecs_cluster_1.name}"
#     propagate_at_launch = true
#   }
# }

# resource "aws_launch_template" "launch_template_1" {
#   name          = "${var.app_ident}-ecs-lt"
#   image_id      = "ami-011a10ed71194b358"
#   instance_type = locals.ec2_instance_type
#   key_name      = locals.ec2_key_name

#   iam_instance_profile {
#     name = aws_iam_instance_profile.ecs_1.name
#   }

#   monitoring {
#     enabled = true
#   }

#   user_data = base64encode(<<-EOF
#               #!/bin/bash
#               echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster_1.name} >> /etc/ecs/ecs.config
#               EOF
#   )

#   vpc_security_group_ids = [aws_security_group.ecs_lt_sg_1.id]
# }

# resource "aws_iam_instance_profile" "ecs_1" {
#   name = "${var.app_ident}_ecs_instance_profile"
#   role = aws_iam_role.ecs_role.name
# }

# resource "aws_security_group" "ecs_lt_sg_1" {
#   name        = "${var.app_ident}-ecs-lt-sg"
#   description = "Allow inbound traffic"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_1_cp_1" {
#   cluster_name = aws_ecs_cluster.ecs_cluster_1.name

#   capacity_providers = [aws_ecs_capacity_provider.ecs_cp_1.name]

#   default_capacity_provider_strategy {
#     capacity_provider = aws_ecs_capacity_provider.ecs_cp_1.name
#     weight            = 1
#     base              = 1
#   }
# }

# resource "aws_ecs_capacity_provider" "ecs_cp_1" {
#   name = "${var.app_ident}-ecs-cp-1"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
#     managed_termination_protection = "DISABLED"  # Ensure this does not conflict with desired capacity

#     managed_scaling {
#       status            = "ENABLED"
#       target_capacity   = 70
#       minimum_scaling_step_size = 1
#       maximum_scaling_step_size = 10
#     }
#   }
# }

# resource "aws_iam_role" "ecs_role" {
#   name = "ecs_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "ecs_role_policy_attachment" {
#   role       = aws_iam_role.ecs_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
# }

# resource "aws_iam_role" "ecs_execution_role" {
#   name = "mycompany_standard_ecs_execution_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         },
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
#   role       = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
