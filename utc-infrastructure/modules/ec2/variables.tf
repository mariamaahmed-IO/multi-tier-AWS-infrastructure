variable "project" {
  description = "Project name"
  type = string
}

variable "env" {
    description = "Enviroment name"
    type = string
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}
variable "public_subnet_id" {
    description = "Public Subnet ID"
    type = list(string)
}
variable "private_subnet_id" {
    description = "Private Subnet ID"
    type = list(string)
    
  
}

variable "bastion_sg_id" {
    description = "Security Group ID for the bastion host"
    type = string
  
}

variable "app_sg_id"{
    description = "Security Group ID for the application servers"
    type = string
  
}
variable "instance_type" {
    description = "EC2 instance type for the application servers"
    type = string
    default = "t2.micro"
  
}

variable "ami_id" {
    description = "AMI ID for the EC2 instances"
    type = string
  
}
variable "key_name" {
    description = "Key pair name for SSH access to EC2 instances"
    type = string
  
}

variable "instance_profile_name" {
  description = "IAM instance profile name to attach to app servers"
  type        = string
  default = ""
}

variable "efs_dns_name" {
  description = "EFS DNS name for mounting"
  type        = string
  default     = ""
}