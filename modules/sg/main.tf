resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.sg_name}"
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.sg_name}"
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for idx, rule in var.ingress_rules :
    "${idx}" => rule
  }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description              = each.value.description
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
