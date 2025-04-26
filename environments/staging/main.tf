# Passing project specific details for VPC
module "vpc" {
  source   = "../../modules/vpc"
  vpc_name = var.vpc_name
}

# Create Public Subnets (2 AZs)
module "public_subnet" {
  source             = "../../modules/subnet"
  vpc_id             = module.vpc.vpc_id
  project_name       = var.project_name
  subnet_name        = var.public_subnet_name
  subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]
  azs                = var.azs
  is_public          = true
  depends_on         = [module.vpc]
}

# Create Private Subnets (2 AZs)
module "private_subnet" {
  source             = "../../modules/subnet"
  vpc_id             = module.vpc.vpc_id
  project_name       = var.project_name
  subnet_name        = var.private_subnet_name
  subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  azs                = var.azs
  is_public          = false
  depends_on         = [module.vpc]
}

# Create Internet Gateway
module "igw" {
  source       = "../../modules/igw"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

# Create NAT Gateway
module "nat_gateway" {
  source           = "../../modules/natgw"
  project_name     = var.project_name
  public_subnet_id = values(module.public_subnet.subnets)[0] # Picking first public subnet to place the NAT
  create_eip       = true
  depends_on       = [module.public_subnet]
}

# Public Route Table
module "public_rtb" {
  source       = "../../modules/rtb"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  subnet_ids   = module.public_subnet.subnets
  is_public    = true
  igw_id       = module.igw.igw_id
  depends_on   = [module.igw]
}

# Private Route Table
module "private_rtb" {
  source         = "../../modules/rtb"
  vpc_id         = module.vpc.vpc_id
  project_name   = var.project_name
  subnet_ids     = module.private_subnet.subnets
  is_public      = false
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

# Create Public Security Group for Bastion Host
module "public_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

# Create Private Security Group for WordPress Instance
module "private_sg" {
  source              = "../../modules/sg"
  vpc_id              = module.vpc.vpc_id
  project_name        = var.project_name
  private_subnet_cidr = "10.0.1.0/24"
}

# Create Bastion Host in 1 of the public subnet
module "ec2_bastion_host" {
  source                 = "../../modules/ec2"
  public_subnet_cidr_az1 = module.public_subnet.subnets[0] # this is the first public subnet in the list of AZ1 public subnet
  project_name           = var.project_name
  security_group_id      = module.public_sg.private_sg_id
  depends_on             = [module.private_sg]
}

# Create WordPress Instance in 1 of the private subnet
module "ec2_wordpress_az1" {
  source                  = "../../modules/ec2"
  private_subnet_cidr_az1 = module.private_subnet.subnets[0] # this is the first private subnet in the list of AZ1 private subnet
  project_name            = var.project_name
  security_group_id       = module.private_sg.private_sg_id
  depends_on              = [module.private_sg]
}

# Create WordPress Instance in second of the private subnet
module "ec2_wordpress_az2" {
  source                  = "../../modules/ec2"
  private_subnet_cidr_az2 = module.private_subnet.subnets[1] # this is the second private subnet in the list of AZ2 private subne
  project_name            = var.project_name
  security_group_id       = module.private_sg.private_sg_id
  depends_on              = [module.private_sg]
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  security_group_id = module.public_sg.public_sg_id                                               # Use the public security group
  subnet_ids        = [module.private_subnet.subnets[0], module.private_subnet.subnets[1]] # Use the public subnets in AZ1 and AZ2
  vpc_id            = module.vpc.vpc_id
}