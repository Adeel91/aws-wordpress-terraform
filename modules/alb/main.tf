resource "aws_lb" "this" {
  name                       = "${var.project_name}-alb"
  internal                   = false # Public-facing ALB
  load_balancer_type         = "application"
  security_groups            = [var.security_group_id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project_name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-target-group"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Forward traffic to the target group
  }
}

# No more direct referencing for wordpress as Autoscaling group is in place
# resource "aws_lb_target_group_attachment" "wordpress_targets_az1" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = var.wordpress_az1_id # Attach first WordPress instance
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "wordpress_targets_az2" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = var.wordpress_az2_id # Attach second WordPress instance
#   port             = 80
# }