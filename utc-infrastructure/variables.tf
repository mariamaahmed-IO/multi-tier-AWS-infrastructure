variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default     = "us-east-1"
  
}

variable "env" {
    description = "The environment for the resources (e.g., dev, staging, prod)."
    type        = string
}

variable "team" {
    description = "The team responsible for the resources."
    type        = string
    default = "config mangement"

}

variable "project" {
    description = "The project name for the resources."
    type        = string
    default = "utc"    
  
}

variable "my_ip" {
  description = "Your local IP for bastion SSH access"
  type        = string
  sensitive   = true
}

variable "ami_id" {
    description = "Amazon Linux 2AMI ID for us-east-1 region"
    type        = string
   
  
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
    
variable "email" {
  description = "Email address for notifications"
  type        = string
}

variable "asg_ami_id" {
    description = "AMI ID for Auto Scaling Group instances"
    type        = string
}