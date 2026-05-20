variable "project" {   
  description = "Project name"
  type = string
  
}

variable "env" {      
    description = "Environment name"
    type = string
  
}
variable "vpc_id" {    
    description = "VPC ID"
    type = string
  
}
variable "public_subnet_ids" {  
    description = "Public Subnet IDs"
    type = list(string)
  
}

variable "alb_sg_id" {
    description = "Security Group ID for the ALB"
    type = string
}

variable "app_server_id" {
    description = "ID of the application server instance"
    type = list(string)
  
}
variable "certificate_arn" {
    description = "ACM certificate ARN of HTTPs listener"
    type = string
    default = ""
}