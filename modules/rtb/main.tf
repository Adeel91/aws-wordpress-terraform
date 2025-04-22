resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.is_public ? "public" : "private"}-rtb"
  }
}

# If public, create a route to the Internet Gateway
resource "aws_route" "default_route" {
  count                  = var.is_public ? 1 : 0
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# Associate subnets with the route table
resource "aws_route_table_association" "this" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}