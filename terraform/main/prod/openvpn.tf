# NOTE: We use a simple openvpn to access private vpn's because this is significantly cheaper than
#       using the AWS VPN built-in option.  Note that this is designed for developer use - not
#       running lots of production traffic through it because this instance is a single point of failure

# locals {
#    vpn_server_cert_arn = "<certificate arn>" 
#    ec2_key_name = "<your ssh key name>"
# }

# resource "aws_security_group" "vpn" {
#   name        = "${var.app_ident}-vpn-sg"
#   description = "Allow VPN traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "Allow OpenVPN"
#     from_port   = 1194
#     to_port     = 1194
#     protocol    = "udp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.app_ident}-vpn-sg"
#   }
# }

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "state"
#     values = ["available"]
#   }
# }

# resource "aws_eip" "vpn" {
#   instance = aws_instance.vpn.id
#   tags = {
#     Name = "${var.app_ident}-vpn-eip"
#   }
# }

# resource "aws_instance" "vpn" {
#   ami           = data.aws_ami.amazon_linux_2.id # Amazon Linux 2 AMI
#   instance_type = "t3.micro"
#   subnet_id     = element(var.public_subnet_ids, 0) # Use the first public subnet

#   vpc_security_group_ids = [aws_security_group.vpn.id]

#   key_name = locals.ec2_key_name

#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

#   tags = {
#     Name = "${var.app_ident}-vpn-instance"
#   }

#   user_data = <<-EOF
#                 #!/bin/bash
#                 # Wait for yum lock to release
#                 while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do
#                     echo "Waiting for yum lock to be released..."
#                     sleep 5
#                 done

#                 # Update the system and enable EPEL for additional packages
#                 yum update -y
#                 yum install -y epel-release

#                 # Install required packages
#                 yum install -y openvpn easy-rsa aws-cli jq

#                 # Set AWS region
#                 AWS_REGION="us-west-2"

#                 # Download the ACM certificate for vpn.<your company>.com
#                 mkdir -p /etc/openvpn/certs
#                 aws acm get-certificate \
#                 --certificate-arn ${locals.vpn_server_cert_arn} \
#                 --region $AWS_REGION \
#                 --output json > /etc/openvpn/certs/vpn_cert.json

#                 # Extract and configure the certificate and key for OpenVPN
#                 cat /etc/openvpn/certs/vpn_cert.json | jq -r '.Certificate' > /etc/openvpn/certs/server.crt
#                 cat /etc/openvpn/certs/vpn_cert.json | jq -r '.CertificateChain' > /etc/openvpn/certs/ca.crt
#                 cat /etc/openvpn/certs/vpn_cert.json | jq -r '.PrivateKey' > /etc/openvpn/certs/server.key

#                 chmod 600 /etc/openvpn/certs/*

#                 # OpenVPN configuration
#                 cat <<EOT > /etc/openvpn/server.conf
#                 port 1194
#                 proto udp
#                 dev tun
#                 ca /etc/openvpn/certs/ca.crt
#                 cert /etc/openvpn/certs/server.crt
#                 key /etc/openvpn/certs/server.key
#                 dh none
#                 topology subnet
#                 server 10.22.0.0 255.255.255.0
#                 push "route 10.10.0.0 255.255.0.0"
#                 keepalive 10 120
#                 persist-key
#                 persist-tun
#                 verb 3
#                 EOT

#                 # Enable and start OpenVPN
#                 systemctl enable openvpn@server
#                 systemctl start openvpn@server
#               EOF
# }

# resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "${var.app_ident}-vpn-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }

# resource "aws_iam_role" "ec2_role" {
#   name = "${var.app_ident}-vpn-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "ec2_policy" {
#   name = "${var.app_ident}-vpn-ec2-policy"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "acm:GetCertificate",
#         Effect = "Allow",
#         Resource = var.vpn_server_cert_arn
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
#   role       = aws_iam_role.ec2_role.name
#   policy_arn = aws_iam_policy.ec2_policy.arn
# }

# resource "aws_cloudwatch_log_group" "vpn_logs" {
#   name = "${var.app_ident}-vpn-logs"
# }

# resource "aws_cloudwatch_log_stream" "vpn_access_log" {
#   name           = "vpn-access-log"
#   log_group_name = aws_cloudwatch_log_group.vpn_logs.name
# }

# output "vpn_instance_public_ip" {
#   value = aws_instance.vpn.public_ip
# }

# /*
# Do the following to generate the client keys you need to use the openvpn

# # ssh into the server

# # enable ip forwarding
# sudo sysctl -w net.ipv4.ip_forward=1

# # traffic forwarding rules
# sudo iptables -A FORWARD -s 10.22.0.0/24 -d 10.10.0.0/16 -j ACCEPT
# sudo iptables -A FORWARD -d 10.22.0.0/24 -s 10.10.0.0/16 -j ACCEPT
# sudo iptables -t nat -A POSTROUTING -s 10.22.0.0/24 -d 10.10.0.0/16 -j MASQUERADE

# cd /etc/openvpn/easy-rsa
# mkdir -p /etc/openvpn/easy-rsa
# cp -r /usr/share/easy-rsa/3/* /etc/openvpn/easy-rsa
# cd easy-rsa/
# ./easyrsa init-pki
# ./easyrsa build-ca nopass
# ./easyrsa sign-req client client1
# ./easyrsa gen-req server nopass
# ./easyrsa sign-req server server

# sudo cp pki/private/server.key /etc/openvpn/certs/
# sudo cp pki/issued/server.crt /etc/openvpn/certs/
# sudo cp pki/ca.crt /etc/openvpn/certs/

# sudo chmod 600 /etc/openvpn/certs/server.key
# sudo chmod 644 /etc/openvpn/certs/server.crt /etc/openvpn/certs/ca.crt
# sudo chown root:root /etc/openvpn/certs/*

# sudo cp /etc/openvpn/easy-rsa/pki/issued/client1.crt ~/
# sudo cp /etc/openvpn/easy-rsa/pki/private/client1.key ~/
# sudo cp /etc/openvpn/easy-rsa/pki/ca.crt ~/

# sudo chown ec2-user ~/*.crt ~/*.key

# scp -i ~/.ssh/<your key>.pem ec2-user@54.202.96.95:/home/ec2-user/client1.crt .
# scp -i ~/.ssh/<your key>.pem ec2-user@54.202.96.95:/home/ec2-user/client1.key .
# scp -i ~/.ssh/<your key>.pem ec2-user@54.202.96.95:/home/ec2-user/ca.crt .

# */
