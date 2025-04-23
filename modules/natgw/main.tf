resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id
  subnet_id     = var.public_subnet_id
  depends_on    = [aws_eip.this]

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}