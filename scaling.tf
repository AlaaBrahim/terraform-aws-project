# Create ALBs
resource "aws_lb" "elb_web" {
  name               = "ELB-Web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_web_sg.id]
  subnets            = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "elb_web_listener" {
  load_balancer_arn = aws_lb.elb_web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}
resource "aws_lb_listener_rule" "elb_web_listener_rule" {
  listener_arn = aws_lb_listener.elb_web_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_web_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb" "elb_app" {
  name               = "ELB-App"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_app_sg.id]
  subnets            = [aws_subnet.private_subnet_az1a.id, aws_subnet.private_subnet_az2a.id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "elb_app_listener" {
  load_balancer_arn = aws_lb.elb_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}
resource "aws_lb_listener_rule" "elb_app_listener_rule" {
  listener_arn = aws_lb_listener.elb_app_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_app_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api*"]
    }
  }
}

# Create Target Groups
resource "aws_lb_target_group" "elb_web_target_group" {
  name        = "ELB-Web-Target-Group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group" "elb_app_target_group" {
  name        = "ELB-App-Target-Group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}

# Create Launch Template
resource "aws_launch_template" "app_server_launch_template" {
  name_prefix            = "app_server_launch_template"
  image_id               = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
}

resource "aws_launch_template" "web_server_launch_template" {
  name_prefix            = "web_server_launch_template"
  image_id               = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
}

resource "aws_autoscaling_group" "app_autoscale" {
  name                 = "app-autoscaling-group"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_subnet_az1a.id, aws_subnet.private_subnet_az2a.id]
  target_group_arns    = [aws_lb_target_group.elb_app_target_group.arn]

  launch_template {
    id      = aws_launch_template.app_server_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "app_scale_down" {
  name                   = "app_scale_down"
  autoscaling_group_name = aws_autoscaling_group.app_autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "app_scale_down" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.app_scale_down.arn]
  alarm_name          = "app_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "5"
  period              = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_autoscale.name
  }
}

resource "aws_autoscaling_policy" "app_scale_up" {
  name                   = "app_scale_up"
  autoscaling_group_name = aws_autoscaling_group.app_autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "app_scale_up" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.app_scale_up.arn]
  alarm_name          = "app_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "75"
  evaluation_periods  = "5"
  period              = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_autoscale.name
  }
}



resource "aws_autoscaling_group" "web_autoscale" {
  name                 = "web-autoscaling-group"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_subnet_az1a.id, aws_subnet.private_subnet_az2a.id]
  target_group_arns    = [aws_lb_target_group.elb_web_target_group.arn]

  launch_template {
    id      = aws_launch_template.web_server_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "web_scale_down" {
  name                   = "web_scale_down"
  autoscaling_group_name = aws_autoscaling_group.web_autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "web_scale_down" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.web_scale_down.arn]
  alarm_name          = "web_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "25"
  evaluation_periods  = "5"
  period              = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_autoscale.name
  }
}

resource "aws_autoscaling_policy" "web_scale_up" {
  name                   = "web_scale_up"
  autoscaling_group_name = aws_autoscaling_group.web_autoscale.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "web_scale_up" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.web_scale_up.arn]
  alarm_name          = "web_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "75"
  evaluation_periods  = "5"
  period              = "30"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_autoscale.name
  }
}
