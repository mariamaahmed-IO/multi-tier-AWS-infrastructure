locals {
  name = "${var.project}-${var.env}"
}

# ─── LAUNCH TEMPLATE ────────────────────────────────────────────────
resource "aws_launch_template" "lt" {
  name        = "${local.name}-lt"
  description = "Launch template for UTC app servers"

  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_sg_id]

  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-efs-utils
    mkdir -p /mnt/efs
    mount -t efs -o tls ${var.efs_dns_name}:/ /mnt/efs
    echo "${var.efs_dns_name}:/ /mnt/efs efs defaults,tls,_netdev 0 0" >> /etc/fstab
    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name}-asg-server"
      env  = var.env
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─── AUTO SCALING GROUP ─────────────────────────────────────────────
resource "aws_autoscaling_group" "asg" {
  name                = "${local.name}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  # ASG notifications via SNS
  initial_lifecycle_hook {
    name                 = "instance-launching"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-asg-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = var.env
    propagate_at_launch = true
  }
}

# ─── SCALE OUT POLICY (CPU high) ────────────────────────────────────
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${local.name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_out_cpu
  alarm_description   = "Scale out when CPU >= ${var.scale_out_cpu}%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn,
    var.sns_topic_arn
  ]
}

# ─── SCALE IN POLICY (CPU low) ──────────────────────────────────────
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${local.name}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale in when CPU <= 20%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn,
    var.sns_topic_arn
  ]
}

# ─── ASG NOTIFICATIONS ──────────────────────────────────────────────
resource "aws_autoscaling_notification" "this" {
  group_names = [aws_autoscaling_group.asg.name]
  topic_arn   = var.sns_topic_arn

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}