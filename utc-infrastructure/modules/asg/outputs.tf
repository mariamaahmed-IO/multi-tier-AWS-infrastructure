output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.asg.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.lt.id
}