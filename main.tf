terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}

# Passing project specific details for VPC
module "vpc" {
  source      = "./modules/vpc"
  vpc_name    = "wordpress-vpc"
}

# Create a Public Subnet
module "public_subnet" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.1.0/24"
  subnet_name             = "public-subnet"
}

# Create a Private Subnet
module "private_subnet" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.2.0/24"
  subnet_name             = "private-subnet"
}