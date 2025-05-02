# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create local variables
locals {
  aws_ami       = data.aws_ami.amazon_linux_2.id
  pem_key       = "vockey"
  instance_type = "t2.micro"

  public_subnet1_cidr = "10.0.0.0/24"
  public_subnet2_cidr = "10.0.2.0/24"

  private_subnet1_cidr = "10.0.1.0/24"
  private_subnet2_cidr = "10.0.3.0/24"

  db_name     = "${var.project_name}db"
  db_username = "admin"
  db_password = "admin12345"
}

# Create random suffix hex
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

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
  subnet_cidr_blocks = [local.public_subnet1_cidr, local.public_subnet2_cidr]
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
  subnet_cidr_blocks = [local.private_subnet1_cidr, local.private_subnet2_cidr]
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
  subnet_ids = {
    for subnet_name, subnet_info in module.public_subnet.subnets :
    subnet_name => subnet_info.id
  }
  is_public  = true
  igw_id     = module.igw.igw_id
  depends_on = [module.igw]
}

# Private Route Table
module "private_rtb" {
  source       = "../../modules/rtb"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  subnet_ids = {
    for subnet_name, subnet_info in module.private_subnet.subnets :
    subnet_name => subnet_info.id
  }
  is_public      = false
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

# Create Public Security Group for Bastion Host
module "public_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  sg_name      = "public-sg"
  description  = "Allow SSH from anywhere"
  ingress_rules = [{
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

# Create Public Security Group for ALB
module "public_lb_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  sg_name      = "alb-sg"
  description  = "Allow HTTP from anywhere"
  ingress_rules = [{
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

# Create Private Security Group for WordPress Instance
module "private_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  sg_name      = "private-sg"
  description  = "Allow SSH from Bastion Host"
  ingress_rules = [{
    description              = "SSH from Bastion"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = [local.public_subnet1_cidr]
    source_security_group_id = module.public_lb_sg.sg_id
  }]
  depends_on = [module.public_lb_sg]
}

# Create Private Security Group for RDS Instance
module "private_rds_sg" {
  source       = "../../modules/sg"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  sg_name      = "rds-sg"
  description  = "Allow access to RDS from EC2"
  ingress_rules = [{
    description              = "MySQL/Aurora"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = module.private_sg.sg_id
  }]
}

# Reference the RDS MariaDB module and pass necessary parameters
module "rds" {
  source       = "../../modules/rds"
  project_name = var.project_name
  db_name      = local.db_name
  db_username  = local.db_username
  db_password  = local.db_password
  private_subnet_ids = [
    module.private_subnet.subnets["${var.project_name}-private-subnet1"].id,
    module.private_subnet.subnets["${var.project_name}-private-subnet2"].id
  ]
  security_group_id = module.private_rds_sg.sg_id
}

# Create EC2 Instances in Public and Private Subnets (Bastion & WordPress)
module "ec2" {
  source        = "../../modules/ec2"
  project_name  = var.project_name
  aws_ami       = local.aws_ami
  key_name      = local.pem_key
  instance_type = local.instance_type

  # Network Subnets and Security Groups
  public_subnet1_id  = module.public_subnet.subnets["${var.project_name}-public-subnet1"].id
  private_subnet1_id = module.private_subnet.subnets["${var.project_name}-private-subnet1"].id
  private_subnet2_id = module.private_subnet.subnets["${var.project_name}-private-subnet2"].id

  public_sg_id  = module.public_sg.sg_id
  private_sg_id = module.private_sg.sg_id

  db_name      = local.db_name
  db_username  = local.db_username
  db_password  = local.db_password
  rds_endpoint = module.rds.rds_instance_endpoint

  depends_on = [module.rds]
}


# Create Application Load Balancer
module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  security_group_id = module.public_lb_sg.sg_id
  subnet_ids = [
    module.public_subnet.subnets["${var.project_name}-public-subnet1"].id,
    module.public_subnet.subnets["${var.project_name}-public-subnet2"].id
  ]
  vpc_id = module.vpc.vpc_id
  # wordpress_az1_id = module.ec2.ec2_instances["${var.project_name}-webserver-az1"].id
  # wordpress_az2_id = module.ec2.ec2_instances["${var.project_name}-webserver-az2"].id
  # depends_on       = [module.ec2]
}

# Create Auto Scaling Group
module "asg" {
  source        = "../../modules/asg"
  project_name  = var.project_name
  ami_id        = local.aws_ami
  instance_type = local.instance_type
  key_name      = local.pem_key

  db_name      = local.db_name
  db_username  = local.db_username
  db_password  = local.db_password
  rds_endpoint = module.rds.rds_instance_endpoint

  private_sg_id = module.private_sg.sg_id

  private_subnet_ids = [
    module.private_subnet.subnets["${var.project_name}-private-subnet1"].id,
    module.private_subnet.subnets["${var.project_name}-private-subnet2"].id
  ]

  target_group_arn = module.alb.target_group_arn

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  depends_on = [module.alb]
}

# Create S3 Bucket
module "s3_static_website" {
  source       = "../../modules/s3"
  project_name = var.project_name
  bucket_name  = "${var.project_name}-static-site-${random_id.bucket_suffix.hex}"
}