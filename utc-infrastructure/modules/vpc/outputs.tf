output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.utc_vpc.id
}

output "vpc_cidr" {
    description = "The CIDR block of the VPC"
    value       = aws_vpc.utc_vpc.cidr_block
  
}

output "public_subnet_id" {
    description = "The IDs of the public subnets"
    value       = aws_subnet.utc_public_subnets[*].id

}
 
 output "private_subnet_id" {
    description = "The IDs of the private subnets"
    value       = aws_subnet.utc_private_subnets[*].id
   
 }

output "nat_gateway_id" {
    description = "The IDs of the NAT Gateways"
    value       = aws_nat_gateway.utc_nat_gw[*].id
}
output "internet_gateway_id" {
    description = "The ID of the Internet Gateway"
    value       = aws_internet_gateway.utc_igw.id
}