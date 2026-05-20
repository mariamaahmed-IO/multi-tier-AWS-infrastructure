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
variable "private_subnet_ids" {
    description = "Private Subnet IDs"
    type = list(string)
  
}
variable "db_sg_id" {
    description = "Security Group ID for the RDS instance"
    type = string
  
}
variable "db_name" {
    description = "Name of the RDS database"
    type = string
    default = "utcdb"
  
}
variable "db_username" {
    description = "Master username for the RDS database"
    type = string
    sensitive = true   
}
variable "db_password" {
    description = "Master password for the RDS database"
    type = string
    sensitive = true
}   
variable "db_instance_class" {
    description = "RDS instance class"
    type = string
    default = "db.t3.micro"
  
}
variable "multi_az" {
    description = "Whether to enable Multi-AZ for RDS (highly available)"
    type = bool
    default = false
}   
variable "skip_final_snapshot" {    
    description = "Whether to skip final snapshot when deleting RDS instance (set to true for dev to save costs, false for prod)"
    type = bool
    default = true  
  
}