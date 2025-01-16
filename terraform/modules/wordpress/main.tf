resource "aws_security_group" "alb_security_group" {
  name        = "${var.project_name}-alb-sg"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
  }
}

# create security group for the bastion host aka jump box
resource "aws_security_group" "bastion_security_group" {
  name        = "${var.project_name}-bastion-sg"
  description = "enable ssh access on port 22"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ssh_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_security_group" "wordpress_webapp_security_group" {
  name        = "${var.project_name}-sg"
  description = "enable http/https access on port 80/443 via alb sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
  }
}

resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.project_name}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [
      aws_security_group.wordpress_webapp_security_group.id,
      aws_security_group.alb_security_group.id,
      var.rds_security_group,
      var.efs_security_group
    ]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    efs_id       = var.efs_id
    db_host      = var.rds_endpoint
    db_name      = var.db_name
    db_user      = var.db_user
    db_password  = var.db_password
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-launch-template"
    }
  }
}

resource "aws_autoscaling_group" "wordpress" {
  name                = "${var.project_name}-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.wordpress.arn]
  vpc_zone_identifier = var.private_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "wordpress_target_tracking" {
  name                   = "${var.project_name}-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}

resource "aws_lb" "wordpress" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.public_subnets

  tags = {
    Name        = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "wordpress" {
  name     = "${var.project_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/phpinfo.php"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}