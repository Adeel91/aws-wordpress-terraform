# Creating Subnet
resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone

  tags = {
    Name = var.subnet_name
  }
}