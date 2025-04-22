# Creating Subnet
resource "aws_subnet" "this" {
  count                   = length(var.subnet_cidr_blocks)
  vpc_id                  = var.vpc_id
  cidr_block              = element(var.subnet_cidr_blocks, count.index)
  availability_zone       = element(var.azs, count.index)  # assign to specific AZ
  map_public_ip_on_launch = var.is_public

  tags = {
    Name = "${var.project_name}-${var.is_public ? "public" : "private"}-subnet${count.index + 1}"
  }
}