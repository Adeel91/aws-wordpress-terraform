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