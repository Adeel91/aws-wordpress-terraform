# Passing project specific details for VPC
module "vpc" {
  source            = "../../modules/vpc"
  vpc_name          = var.staging_vpc_name
}

# # Create a Public Subnet
# module "public_subnet" {
#   source            = "../../modules/subnet"
#   vpc_id            = module.vpc.vpc_id
#   subnet_cidr       = var.public_cidr_block
#   subnet_name       = var.public_subnet_name
#   depends_on        = [ module.vpc ]
# }

# # Create a Private Subnet
# module "private_subnet" {
#   source            = "../../modules/subnet"
#   vpc_id            = module.vpc.vpc_id
#   subnet_cidr       = var.private_cidr_block
#   subnet_name       = var.private_subnet_name
#   depends_on        = [ module.vpc ]
# }