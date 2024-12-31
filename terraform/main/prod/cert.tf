# # NOTE: This assumes you have your domain in Route53

# locals {
#     domain_name = "mydomain.com"
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = locals.domain_name
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${locals.domain_name}",
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "${locals.domain_name} SSL Certificate"
#   }
# }

# resource "aws_acm_certificate" "cert_useast1" {
#   provider = aws.useast1
#   domain_name       = locals.domain_name
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${locals.domain_name}",
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "${locals.domain_name} useast1 SSL Certificate"
#   }
# }
