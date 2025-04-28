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
  public_subnet_id = module.public_subnet.subnets["${var.project_name}-public-subnet1"].id # Picking first public subnet to place the NAT
  create_eip       = true
  depends_on       = [module.public_subnet]
}

# Public Route Table
module "public_rtb" {
  source       = "../../modules/rtb"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  subnet_ids   = [for subnet in module.public_subnet.subnets : subnet.id]
  is_public    = true
  igw_id       = module.igw.igw_id
  depends_on   = [module.igw]
}

# Private Route Table
module "private_rtb" {
  source         = "../../modules/rtb"
  vpc_id         = module.vpc.vpc_id
  project_name   = var.project_name
  subnet_ids     = [for subnet in module.public_subnet.subnets : subnet.id]
  is_public      = false
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

# Create Public Security Group for Bastion Host
module "public_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  subnet_cidr  = ["0.0.0.0/0"]
}

# Create Private Security Group for WordPress Instance
module "private_sg" {
  source              = "../../modules/sg"
  vpc_id              = module.vpc.vpc_id
  project_name        = var.project_name
  subnet_cidr         = [module.public_subnet.subnets["${var.project_name}-public-subnet1"].cidr] # Only allow Bastion's Host subnet to SSH
}

# Create Public Security Group for ALB
module "public_lg_sg" {
  source              = "../../modules/sg"
  vpc_id              = module.vpc.vpc_id
  project_name        = var.project_name
  subnet_cidr         = ["0.0.0.0/0"]
}

# Create Private Security Group for RDS Instance
module "private_rds_sg" {
  source              = "../../modules/sg"
  vpc_id              = module.vpc.vpc_id
  project_name        = var.project_name
  subnet_cidr         = [
    module.private_subnet.subnets["${var.project_name}-private-subnet1"].cidr,  # Subnet in AZ1
    module.private_subnet.subnets["${var.project_name}-private-subnet2"].cidr   # Subnet in AZ2
  ]
}

# Create Bastion Host in 1 of the public subnet
module "ec2_bastion_host" {
  source                 = "../../modules/ec2"
  public_subnet_cidr_az1 = module.public_subnet.subnets["${var.project_name}-public-subnet1"].cidr # this is the first public subnet in the list of AZ1 public subnet
  project_name           = var.project_name
  security_group_id      = module.public_sg.private_sg_id
  depends_on             = [module.private_sg]
}

# Create WordPress Instance in 1 of the private subnet
module "ec2_wordpress_az1" {
  source                  = "../../modules/ec2"
  private_subnet_cidr_az1 = module.private_subnet.subnets["${var.project_name}-private-subnet1"].cidr # this is the first private subnet in the list of AZ1 private subnet
  project_name            = var.project_name
  security_group_id       = module.private_sg.private_sg_id
  depends_on              = [module.private_sg]
}

# Create WordPress Instance in second of the private subnet
module "ec2_wordpress_az2" {
  source                  = "../../modules/ec2"
  private_subnet_cidr_az2 = module.private_subnet.subnets["${var.project_name}-private-subnet2"].cidr # this is the second private subnet in the list of AZ2 private subnet
  project_name            = var.project_name
  security_group_id       = module.private_sg.private_sg_id
  depends_on              = [module.private_sg]
}

# Reference the RDS MariaDB module and pass necessary parameters
module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  db_name               = "aws-wordpress-terraform"
  db_username           = "root"
  db_password           = "root"
  private_subnet_ids    = [module.private_subnet.subnets["${var.project_name}-private-subnet1"].cidr, module.private_subnet.subnets["${var.project_name}-private-subnet2"].cidr]
  security_group_id     = module.private_rds_sg.private_rds_sg_id
  db_subnet_group_name  = "${var.project_name}-mariadb-subnet-group"
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  security_group_id = module.public_lg_sg.public_lb_sg_id
  subnet_ids        = [module.public_subnet.subnets["${var.project_name}-public-subnet1"].cidr, module.public_subnet.subnets["${var.project_name}-public-subnet2"].cidr] # Use the public subnets in AZ1 and AZ2
  vpc_id            = module.vpc.vpc_id
  wordpress_az1_id  = module.ec2_wordpress_az1.ec2_wordpress_az1_id
  wordpress_az2_id  = module.ec2_wordpress_az2.ec2_wordpress_az2_id
}