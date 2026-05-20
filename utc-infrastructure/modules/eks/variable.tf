variable "cluster_name" {
  description = "The name of the cluster"
  type        = string

}

variable "cluster_version" {
  description = "The version of the cluster"
  type        = string
  default     = "1.32"

}

variable "vpc_id" {
  description = "The VPC ID where the cluster will be deployed"
  type        = string

}

variable "private_subnet_ids" {
  description = "List of private subnet IDs worker nodes"
  type        = list(string)

}
variable "public_subnet_ids" {
  description = "List of public subnet IDs for load balancers"
  type        = list(string)

}

variable "node_group_instance_type" {
  description = "The EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"

}

variable "node_group_min_size" {
  description = "The minimum number of worker nodes"
  type        = number
  default     = 1
}
variable "node_group_max_size" {
  description = "The maximum number of worker nodes"
  type        = number
  default     = 5

}
variable "node_group_desired_size" {
  description = "The desired number of worker nodes"
  type        = number
  default     = 2

}
variable "env" {
  description = "The environment for the cluster"
  type        = string
}