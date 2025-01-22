# data "aws_key_pair" "mycompany_devops" {
#   key_name = "mycompany_devops"
# }

# variable "vpc_id" {
#     type = string
# }

# variable "public_subnet_ids" {
#     type = list(string)
# }

# resource "aws_security_group" "github_runner_sg" {
#   name_prefix = "mycompany-github-runner-sg"
#   vpc_id = var.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP range for better security
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "github_runner" {
#   ami           = data.aws_ami.amazon_linux_2.id
#   instance_type = "t3.micro"
#   key_name      = data.aws_key_pair.mycompany_devops.key_name
#   vpc_security_group_ids = [
#     aws_security_group.github_runner_sg.id
#   ]
#   subnet_id = var.public_subnet_ids[0]
#   associate_public_ip_address = true

#   tags = {
#     Name = "GitHub Runner"
#   }

# NOTE: this isn't perfect yet, you may need to run the ./config.sh manually yourself before this whole thing works
#   user_data = <<-EOT
#         #!/bin/bash
#         # Download and install the GitHub Actions runner
#         curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz
#         mkdir /opt/actions-runner
#         tar xzf actions-runner-linux-x64-2.321.0.tar.gz -C /opt/actions-runner
#         rm -f actions-runner-linux-x64-2.321.0.tar.gz
#         cd /opt/actions-runner/
#         chown -R ec2-user /opt/actions-runner/

#         # Configure the runner
#         sudo -u ec2-user ./config.sh \
#         --url <my github url> \  # Example: https://github.com/NRD-Tech/my-cool-project
#         --token <my token> \
#         --name "$(hostname)" \
#         --work "_work" \
#         --labels "self-hosted,linux,x64" \
#         --runnergroup "Default"

#         # Create the systemd service file
#         echo '[Unit]
#         Description=GitHub Actions Runner
#         After=network.target

#         [Service]
#         ExecStart=/opt/actions-runner/run.sh
#         WorkingDirectory=/opt/actions-runner
#         User=ec2-user
#         Restart=always
#         RestartSec=10

#         [Install]
#         WantedBy=multi-user.target' > /etc/systemd/system/github-runner.service

#         # Reload systemd to pick up the new service file
#         systemctl daemon-reload

#         # Enable and start the service
#         systemctl enable github-runner.service
#         systemctl start github-runner.service

#         echo "GitHub Actions runner installed, configured, and running as a service."
#     EOT
# }

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }
