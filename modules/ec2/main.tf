resource "aws_instance" "bastion" {
  ami                         = "ami-0440d3b780d96b29d"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_cidr_az1
  vpc_security_group_ids      = [module.public_sg.public_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_instance" "wordpress_az1" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_cidr_az1
  vpc_security_group_ids = [module.private_sg.private_sg_id]
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-wordpress-az1"
  }
}

resource "aws_instance" "wordpress_az2" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_cidr_az2
  vpc_security_group_ids = [module.private_sg.private_sg_id]
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-wordpress-az2"
  }
}
