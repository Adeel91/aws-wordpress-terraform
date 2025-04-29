data "template_file" "wordpress_setup" {
  template = file("${path.module}/scripts/wordpress-setup.sh")

  # Pass the dynamic variables to the template
  vars = {
    DB_HOST = var.rds_endpoint
    DB_NAME = var.db_name
    DB_USER = var.db_username
    DB_PASS = var.db_password
  }
}

locals {
  instances = [
    {
      name                        = "bastion-host"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.public_subnet1_id
      security_group_ids          = [var.public_sg_id]
      associate_public_ip_address = true
      key_name                    = var.key_name
      user_data                   = file("${path.module}/scripts/bastion-setup.sh")
      tags                        = { Name = "${var.project_name}-bastion" }
    },
    {
      name                        = "wordpress-webserver-az1"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.private_subnet1_id
      security_group_ids          = [var.private_sg_id]
      associate_public_ip_address = false
      key_name                    = var.key_name
      user_data                   = data.template_file.wordpress_setup.rendered
      tags                        = { Name = "${var.project_name}-webserver-az1" }
      root_block_device = [{
        volume_size = 8
        volume_type = "gp2"
        encrypted   = true
      }]
    },
    {
      name                        = "wordpress-webserver-az2"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.private_subnet2_id
      security_group_ids          = [var.private_sg_id]
      associate_public_ip_address = false
      key_name                    = var.key_name
      user_data                   = data.template_file.wordpress_setup.rendered
      tags                        = { Name = "${var.project_name}-webserver-az2" }
      root_block_device = [{
        volume_size = 8
        volume_type = "gp2"
        encrypted   = true
      }]
    }
  ]
}

resource "aws_instance" "this" {
  for_each = { for idx, instance in local.instances : instance.name => instance }

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                    = each.value.key_name
  user_data                   = each.value.user_data
  tags                        = each.value.tags

  # Dynamically creating the root_block_device if it exists in the instance definition
  dynamic "root_block_device" {
    for_each = (lookup(each.value, "root_block_device", null) != null) ? [each.value.root_block_device] : []

    content {
      volume_size = root_block_device.value[0].volume_size
      volume_type = root_block_device.value[0].volume_type
      encrypted   = root_block_device.value[0].encrypted
    }
  }
}