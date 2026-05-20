variable "project" {
  description = "The project name for the resources."
  type        = string

}

variable "env" {
  description = "The environment for the resources (e.g., dev, staging, prod)."
  type        = string

}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

}

variable "private_subnet_cidr" {
  description = "Cidr blocks for private subnets( two per AZ = 6 total)"
  type        = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24", # 1a app + db
    "10.10.13.0/24", "10.10.14.0/24",          # 1b app + db
    "10.10.15.0/24", "10.10.16.0/24"           # 1c app + db
  ]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets."
  type        = bool
  default     = true

}

variable "single_nate_gateway" {
  description = " to create a single NAT Gateway for all private subnets "
  type        = bool
  default     = false

}