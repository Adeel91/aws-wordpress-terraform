# Passing project specific details for VPC
module "vpc" {
  source            = "../../modules/vpc"
  vpc_name          = var.vpc_name
}

# Create Public Subnets (2 AZs)
module "public_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  project_name      = var.project_name
  subnet_name       = var.public_subnet_name
  subnet_cidr_blocks= ["10.0.0.0/24", "10.0.2.0/24"]
  azs               = var.azs
  is_public         = true
  depends_on        = [module.vpc]
}

# Create Private Subnets (2 AZs)
module "private_subnet" {
  source            = "../../modules/subnet"
  vpc_id            = module.vpc.vpc_id
  project_name      = var.project_name
  subnet_name       = var.private_subnet_name
  subnet_cidr_blocks= ["10.0.1.0/24", "10.0.3.0/24"]
  azs               = var.azs
  is_public         = false
  depends_on        = [module.vpc]
}

# Create Internet Gateway
module "igw" {
  source            = "../../modules/igw"
  vpc_id            = module.vpc.vpc_id
  project_name      = var.project_name
}