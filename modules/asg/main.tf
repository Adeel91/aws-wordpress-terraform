resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.private_sg_id]
  }

  user_data = base64encode(templatefile("${path.root}/scripts/wordpress-setup.sh", {
    DB_HOST = var.rds_endpoint != "" ? var.rds_endpoint : "localhost"
    DB_NAME = var.db_name != "" ? var.db_name : "db"
    DB_USER = var.db_username != "" ? var.db_username : "admin"
    DB_PASS = var.db_password != "" ? var.db_password : "admin123"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-launch-template"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp2"
      encrypted   = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_group" {
  name                      = "${var.project_name}-asg-group"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-wordpress-asg-group"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "${var.project_name}-asg-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}

resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "${var.project_name}-asg-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
}
