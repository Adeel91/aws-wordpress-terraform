locals {
  instances = [
    {
      name                        = "bastion_host"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.public_subnet_cidr_az1
      security_group_ids          = [var.public_sg_id]
      associate_public_ip_address = true
      key_name                    = var.key_name
      user_data                   = file("${path.module}/scripts/bastion-setup.sh")
      tags                        = { Name = "${var.project_name}-bastion" }
    },
    {
      name                        = "wordpress_az1"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.private_subnet_cidr_az1
      security_group_ids          = [var.private_sg_id]
      associate_public_ip_address = false
      key_name                    = var.key_name
      user_data                   = file("${path.module}/scripts/wordpress-setup.sh")
      tags                        = { Name = "${var.project_name}-wordpress-az1" }
      root_block_device           = [{
        volume_size = 20
        volume_type = "gp2"
        encrypted   = true
      }]
    },
    {
      name                        = "wordpress_az2"
      ami                         = var.aws_ami
      instance_type               = "t2.micro"
      subnet_id                   = var.private_subnet_cidr_az2
      security_group_ids          = [var.private_sg_id]
      associate_public_ip_address = false
      key_name                    = var.key_name
      user_data                   = file("${path.module}/scripts/wordpress-setup.sh")
      tags                        = { Name = "${var.project_name}-wordpress-az2" }
      root_block_device           = [{
        volume_size = 20
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

  dynamic "root_block_device" {
    for_each = each.value.root_block_device != null ? [each.value.root_block_device] : []
    content {
      volume_size = root_block_device.value[0].volume_size
      volume_type = root_block_device.value[0].volume_type
      encrypted   = root_block_device.value[0].encrypted
    }
  }
}

# resource "aws_instance" "ec2_bastion_host" {
#   ami                         = var.aws_ami
#   instance_type               = "t2.micro"
#   subnet_id                   = var.public_subnet_cidr_az1
#   vpc_security_group_ids      = [var.security_group_id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name
#   user_data                   = file("${path.module}/scripts/bastion-setup.sh")

#   tags = {
#     Name = "${var.project_name}-bastion"
#   }
# }

# resource "aws_instance" "ec2_wordpress_az1" {
#   ami                         = var.aws_ami
#   instance_type               = "t2.micro"
#   subnet_id                   = var.private_subnet_cidr_az1
#   vpc_security_group_ids      = [var.security_group_id]
#   key_name                    = var.key_name
#   associate_public_ip_address = false
#   user_data                   = file("${path.module}/scripts/wordpress-setup.sh")

#   root_block_device {
#     volume_size = 20
#     volume_type = "gp2"
#     encrypted   = true
#   }

#   tags = {
#     Name = "${var.project_name}-wordpress-az1"
#   }
# }

# resource "aws_instance" "ec2_wordpress_az2" {
#   ami                         = var.aws_ami
#   instance_type               = "t2.micro"
#   subnet_id                   = var.private_subnet_cidr_az2
#   vpc_security_group_ids      = [var.security_group_id]
#   key_name                    = var.key_name
#   associate_public_ip_address = false
#   user_data                   = file("${path.module}/scripts/wordpress-setup.sh")

#   root_block_device {
#     volume_size = 20
#     volume_type = "gp2"
#     encrypted   = true
#   }

#   tags = {
#     Name = "${var.project_name}-wordpress-az2"
#   }
# }
