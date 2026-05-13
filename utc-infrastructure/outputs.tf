# outputs.tf (root)

# ─── VPC OUTPUTS ────────────────────────────────────────────────────
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_id
}

# ─── SECURITY GROUP OUTPUTS ─────────────────────────────────────────
output "alb_sg_id" {
  description = "ALB security group ID"
  value       = module.security_groups.alb_sg_id
}

output "app_sg_id" {
  description = "App server security group ID"
  value       = module.security_groups.app_sg_id
}

output "database_sg_id" {
  description = "Database security group ID"
  value       = module.security_groups.db_sg_id
}

# ─── EC2 OUTPUTS ────────────────────────────────────────────────────
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.ec2.bastion_public_ip
}

output "app_server_private_ips" {
  description = "Private IPs of the app servers"
  value       = module.ec2.app_server_private_ips
}

output "app_server_ids" {
  description = "IDs of the app servers"
  value       = module.ec2.app_server_ids
}

output "key_name" {
  description = "Key pair name"
  value       = module.ec2.key_name
}

output "alb_dns_name" {
  description = "ALB DNS name - use this to access the app"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "Target group ARN for ASG attachment later"
  value       = module.alb.target_group_arn
}

# ─── RDS OUTPUTS ───────────────────────────────────────────────────
output "db_endpoint" {
  description = "RDS endpoint for app server connection"
  value       = module.rds.db_endpoint
}

output "s3_bucket_id" {
  description = "S3 logs bucket name"
  value       = module.s3.bucket_id
}

output "efs_dns_name" {
    description = "EFS DNS name for app server mounting"
    value       = module.efs.efs_dns_name
  
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}
output "github_actions_plan_role_arn" {
  value       = module.iam.github_actions_plan_role_arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN"
}

output "github_actions_apply_role_arn" {
  value       = module.iam.github_actions_apply_role_arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN_APPLY"
}