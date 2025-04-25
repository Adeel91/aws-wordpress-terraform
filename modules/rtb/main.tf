resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.is_public ? "public" : "private"}-rtb"
  }
}

# If public, create a route to the Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id     = var.is_public ? var.igw_id : null
  nat_gateway_id = var.is_public ? null : var.nat_gateway_id

  lifecycle {
    ignore_changes = [gateway_id, nat_gateway_id]
  }

  depends_on = [
    aws_route_table.this
  ]
}

# Associate subnets with the route table
resource "aws_route_table_association" "this" {
  for_each       = var.subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}