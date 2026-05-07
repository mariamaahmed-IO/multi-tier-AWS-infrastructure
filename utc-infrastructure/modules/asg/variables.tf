variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "app_sg_id" {
  description = "App server security group ID"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "efs_dns_name" {
  description = "EFS DNS name for mounting"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "scale_out_cpu" {
  description = "CPU % to trigger scale out"
  type        = number
  default     = 80
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
}