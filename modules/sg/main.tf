resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.sg_name}"
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.sg_name}"
  }
}

# resource "aws_security_group" "public_sg" {
#   name        = "${var.project_name}-public-sg"
#   description = "Allow public access to public resources (e.g., EC2)"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "Allow SSH from anywhere"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.subnet_cidr
#   }

#   # Allow all outbound traffic
#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-public-sg"
#   }
# }

# resource "aws_security_group" "private_sg" {
#   name        = "${var.project_name}-private-sg"
#   description = "Allow internal communication between private resources"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "SSH from Bastion Host"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.subnet_cidr # Bastion's public subnet CIDR only to allow ssh with Bastion SG
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # Allow all outbound traffic
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-private-sg"
#   }
# }

# resource "aws_security_group" "public_lb_sg" {
#   name        = "${var.project_name}-public-lb-sg"
#   vpc_id      = var.vpc_id
#   description = "Allow HTTP from anywhere"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = var.subnet_cidr
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-public-lb-sg"
#   }
# }

# resource "aws_security_group" "private_rds_sg" {
#   name        = "${var.project_name}-private-rds-sg"
#   description = "Allow access to MariaDB RDS from EC2 instances in private subnets"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "SSH from Bastion Host"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = var.subnet_cidr
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # Allow all outbound traffic
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-private-rds-sg"
#   }
# }