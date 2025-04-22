# Creating Subnet
resource "aws_subnet" "this" {
  count                   = length(var.azs)
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.subnet_cidr, 8, count.index)  # dnamically calculate cidr block
  availability_zone       = element(var.azs, count.index)  # assign to specific AZ
  map_public_ip_on_launch = var.is_public

  tags = {
    Name = "${var.subnet_name}-${element(var.azs, count.index)}"
  }
}