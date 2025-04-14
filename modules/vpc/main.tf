# Creating VPC
resource "aws_vpc" "wordpress-vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = var.wordpress_vpc_name
  }
}