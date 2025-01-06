# variable "ec2_key_name" {
#   description = "The name of the EC2 key pair to use. If not specified, a new key pair will be created."
#   default     = ""
# }

# locals {
#   # If you do not want any EC2 capacity just set these both to 0
#   min_num_servers   = 1
#   max_num_servers   = 1

#   subnet_ids        = var.public_subnet_ids  # var.private_subnet_ids or var.public_subnet_ids
#   ec2_instance_type = var.ecs_ec2_cpu_architecture == "X86_64" ? "t3.large" : "t4g.large"
#   ec2_key_name      = var.ec2_key_name != "" ? var.ec2_key_name : aws_key_pair.generated_key[0].key_name
# }

# resource "aws_ecs_cluster" "ecs_cluster_ec2_1" {
#   name = "${var.app_ident}-ec2-ecs-cluster-1"

#   setting {
#     name  = "containerInsights"
#     value = "enabled" # enabled or enhanced
#   }
# }

# output "ecs_cluster_ec2_1" {
#   value = aws_ecs_cluster.ecs_cluster_ec2_1.id
# }

# resource "aws_autoscaling_group" "ecs_1" {
#   name = "${var.app_ident}-ecs-asg"
#   desired_capacity     = local.min_num_servers
#   min_size             = local.min_num_servers
#   max_size             = local.max_num_servers
#   vpc_zone_identifier  = local.subnet_ids
#   protect_from_scale_in  = true  # Protect instances from being scaled in
#   default_cooldown = 60

#   launch_template {
#     id      = aws_launch_template.launch_template_1.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "ECS - ${aws_ecs_cluster.ecs_cluster_ec2_1.name}"
#     propagate_at_launch = true
#   }
# }

# resource "aws_launch_template" "launch_template_1" {
#   name          = "${var.app_ident}-ecs-lt"
#   image_id      = var.ecs_ec2_cpu_architecture == "X86_64" ? data.aws_ssm_parameter.ecs_optimized_ami.value : data.aws_ssm_parameter.ecs_optimized_ami_arm64.value
  
#   instance_type = local.ec2_instance_type
#   key_name      = local.ec2_key_name

#   iam_instance_profile {
#     name = aws_iam_instance_profile.ecs_1.name
#   }

#   monitoring {
#     enabled = true
#   }

#   user_data = base64encode(<<-EOF
#               #!/bin/bash
#               echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster_ec2_1.name} >> /etc/ecs/ecs.config
#               EOF
#   )

#   vpc_security_group_ids = [aws_security_group.ecs_lt_sg_1.id]
# }

# data "aws_ssm_parameter" "ecs_optimized_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
# }

# data "aws_ssm_parameter" "ecs_optimized_ami_arm64" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id"
# }

# resource "aws_key_pair" "generated_key" {
#   count      = var.ec2_key_name == "" ? 1 : 0
#   key_name   = "${var.app_ident}-generated-key"
#   public_key = tls_private_key.generated_key.public_key_openssh
# }

# resource "tls_private_key" "generated_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
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

# resource "aws_ecs_cluster_capacity_providers" "ec2_ecs_cluster_1_cp" {
#   cluster_name       = aws_ecs_cluster.ecs_cluster_ec2_1.name
#   capacity_providers = [aws_ecs_capacity_provider.ecs_cp_1.name]
# }

# resource "aws_ecs_capacity_provider" "ecs_cp_1" {
#   name = "${var.app_ident}-ecs-cp-1"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.ecs_1.arn
#     managed_termination_protection = "ENABLED"

#     managed_scaling {
#       status                  = "ENABLED"
#       target_capacity         = 100 # Ensure full utilization of ASG capacity
#       minimum_scaling_step_size = 1
#       maximum_scaling_step_size = 1 # Prevent large, unexpected scaling steps
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
