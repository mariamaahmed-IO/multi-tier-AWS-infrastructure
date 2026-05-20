output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_alb.alb.dns_name
}
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_alb.alb.arn

}
output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_alb_target_group.tg.arn

}
output "http_listener_arn" {
  description = "The ARN of the HTTP Listener"
  value       = aws_alb_listener.http_listener.arn

}