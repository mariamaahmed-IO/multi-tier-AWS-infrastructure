variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "app_sg_id" {
  description = "App server security group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "azs" {
    description = "List of availability zones for EFS mount targets"
    type        = list(string)
  
}