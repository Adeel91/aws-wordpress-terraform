# Passing project specific details for VPC
module "vpc" {
  source            = "../../modules/vpc"
  vpc_name          = "wordpress-vpc" # var.staging_vpc_name
}

# Create a Public Subnet
module "public_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  subnet_cidr       = "10.0.1.0/24" # var.public_cidr_block
  subnet_name       = "public-subnet" # var.public_subnet_name
  depends_on        = [ module.vpc ]
}

# Create a Private Subnet
module "private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  subnet_cidr       = "10.0.2.0/24" # var.private_cidr_block
  subnet_name       = "private-subnet" # var.private_subnet_name
  depends_on        = [ module.vpc ]
}