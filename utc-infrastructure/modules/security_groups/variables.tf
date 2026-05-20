variable "project" {   
    description = "The project name for the resources."
    type        = string
  
}

variable "env" {
    description = "The environment for the resources (e.g., dev, staging, prod)."
    type        = string
  
}

variable "vpc_id" {  
    description = "The ID of the VPC where security groups will be created."
    type        = string
  
}

variable "my_ip" {
    description = "Your current IP address for allowing SSH access to bastion host."
    type        = string
    sensitive = true
  
}