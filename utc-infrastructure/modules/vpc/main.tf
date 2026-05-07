locals {
  name_prefix = "${var.project}-${var.env}"
}
resource "aws_vpc" "utc_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "${local.name_prefix}-vpc"
    }
  
}

# Internet Gateway
resource "aws_internet_gateway" "utc_igw" {
    vpc_id = aws_vpc.utc_vpc.id
    tags = {
        Name = "${local.name_prefix}-igw"
    }
}

#---Public Subnets
resource "aws_subnet" "utc_public_subnets" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.utc_vpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.azs[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "${local.name_prefix}-public-subnet-${count.index + 1}" #check this compared to ${var.azs[count.index]}"
        Tier = "public"
    }
}

#---Private Subnets
resource "aws_subnet" "utc_private_subnets" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.utc_vpc.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = var.azs[count.index % length(var.azs)] # Distribute private subnets across AZs
    map_public_ip_on_launch = false
    tags = {
        Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
        Tier = "private"
    } 
}

# ---Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    count = var.enable_nat_gateway && !var.single_nate_gateway ? length(var.azs) : var.enable_nat_gateway && var.single_nate_gateway ? 1 : 0
    tags = {
        Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
    depends_on = [aws_internet_gateway.utc_igw]
}  

# ---NAT Gateway
resource "aws_nat_gateway" "utc_nat_gw" {
    count = var.enable_nat_gateway ? (var.single_nate_gateway ? 1 : length(var.azs)) : 0
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.utc_public_subnets[count.index % length(var.azs)].id
    tags = {
        Name = "${local.name_prefix}-nat-gw-${count.index + 1}"
    }
    depends_on = [aws_internet_gateway.utc_igw]
}

#---Route Table for Public Subnets
resource "aws_route_table" "utc_public_rt" {
    vpc_id = aws_vpc.utc_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.utc_igw.id
    }

tags = {
    Name = "${local.name_prefix}-public-rt"
}
}

resource "aws_route_table_association" "public_rt_assoc" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.utc_public_subnets[count.index].id
    route_table_id = aws_route_table.utc_public_rt.id
  
}

#---Route Table for Private Subnets ( one per az)
resource "aws_route_table" "utc_private_rt" {
    count = length(var.azs)
    vpc_id = aws_vpc.utc_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = var.enable_nat_gateway ? (
        var.single_nate_gateway
        ? aws_nat_gateway.utc_nat_gw[0].id
        : aws_nat_gateway.utc_nat_gw[count.index].id
    ) : null
  }


    tags = {
        Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    }
}

resource "aws_route_table_association" "private_rt_assoc" {
    count = length(var.private_subnet_cidr)
    subnet_id = aws_subnet.utc_private_subnets[count.index].id
    route_table_id = aws_route_table.utc_private_rt[count.index % length(var.azs)].id
  
}