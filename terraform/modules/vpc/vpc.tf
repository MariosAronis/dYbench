# Create VPC
resource "aws_vpc" "dybench" {
  cidr_block           = "${var.cidr_prefix_testnet}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.environment_name
  }
}

# Create public subnet 
resource "aws_subnet" "dybench-sn-public" {
  vpc_id                  = aws_vpc.dybench.id
  cidr_block              = "${var.cidr_prefix_testnet}.0.0/24"
  availability_zone       = var.az-1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment_name}-public"
  }
}

# Create private subnet
resource "aws_subnet" "dybench-sn-priv" {
  vpc_id                  = aws_vpc.dybench.id
  cidr_block              = "${var.cidr_prefix_testnet}.1.0/24"
  availability_zone       = var.az-1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment_name}-priv"
  }
}

# Create IGW
resource "aws_internet_gateway" "dybench-ig" {
  vpc_id = aws_vpc.dybench.id

  tags = {
    Name = var.environment_name
  }
}

# Create NAT GW & EIP for NAT GW
resource "aws_eip" "dybench-ip-nat" {

  tags = {
    Name = var.environment_name
  }
}

resource "aws_nat_gateway" "dybench-nat" {
  allocation_id = aws_eip.dybench-ip-nat.id
  subnet_id     = aws_subnet.dybench-sn-public.id

  tags = {
    Name = var.environment_name
  }
}

# Handle default route and rename to public
resource "aws_default_route_table" "dybench-rtb-public" {
  default_route_table_id = aws_vpc.dybench.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dybench-ig.id
  }

  route {
    cidr_block                = "${var.cidr_prefix_vpn}.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.dybench-vpn.id
  }

  tags = {
    Name = "${var.environment_name}-public"
  }
}

# Associate route table to public subnet
resource "aws_route_table_association" "dybench-associate-r-s-public" {
  subnet_id      = aws_subnet.dybench-sn-public.id
  route_table_id = aws_default_route_table.dybench-rtb-public.id
}

# Create route table for private subnet
resource "aws_route_table" "dybench-rtb-private" {
  vpc_id = aws_vpc.dybench.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dybench-nat.id
  }

  route {
    cidr_block                = "${var.cidr_prefix_vpn}.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.dybench-vpn.id
  }
}

# Associate route table to private subnet
resource "aws_route_table_association" "dybench-associate-r-s-private" {
  subnet_id      = aws_subnet.dybench-sn-priv.id
  route_table_id = aws_route_table.dybench-rtb-private.id
}

##############################################################################
# Following Section creates the networking recources needed for the vpn server
##############################################################################

# Create VPC for vpn server
resource "aws_vpc" "dybench-vpn" {
  cidr_block           = "${var.cidr_prefix_vpn}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.environment_name}-vpn"
  }
}

# Create public subnet for vpn server
resource "aws_subnet" "dybench-vpn-sn-public" {
  vpc_id                  = aws_vpc.dybench-vpn.id
  cidr_block              = "${var.cidr_prefix_vpn}.0.0/24"
  availability_zone       = var.az-1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment_name}-vpn-public"
  }
}

# Create private subnet for vpn server
resource "aws_subnet" "dybench-vpn-sn-priv" {
  vpc_id                  = aws_vpc.dybench-vpn.id
  cidr_block              = "${var.cidr_prefix_vpn}.1.0/24"
  availability_zone       = var.az-1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment_name}-vpn-priv"
  }
}

# Create IGW for vpn server
resource "aws_internet_gateway" "dybench-vpn-ig" {
  vpc_id = aws_vpc.dybench-vpn.id

  tags = {
    Name = var.environment_name
  }
}

# Create NAT GW for vpn server & EIP for NAT GW
resource "aws_eip" "dybench-vpn-ip-nat" {

  tags = {
    Name = var.environment_name
  }
}

resource "aws_nat_gateway" "dybench-vpn-nat" {
  allocation_id = aws_eip.dybench-vpn-ip-nat.id
  subnet_id     = aws_subnet.dybench-vpn-sn-public.id

  tags = {
    Name = var.environment_name
  }
}

# Handle default route and rename to public
resource "aws_default_route_table" "dybench-vpn-rtb-public" {
  default_route_table_id = aws_vpc.dybench-vpn.default_route_table_id

  # Route to world
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dybench-vpn-ig.id
  }
  
  # Peering Route to testnet public network 
  route {
    cidr_block                = "${var.cidr_prefix_testnet}.0.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.dybench-vpn.id
  }

  # Peering Route to testnet private network 
  route {
    cidr_block                = "${var.cidr_prefix_testnet}.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.dybench-vpn.id
  }

  tags = {
    Name = "${var.environment_name}-vpn-public"
  }

  
}

# Associate route table to public subnet
resource "aws_route_table_association" "dybench-vpn-associate-r-s-public" {
  subnet_id      = aws_subnet.dybench-vpn-sn-public.id
  route_table_id = aws_default_route_table.dybench-vpn-rtb-public.id
}

# # Create route table for private subnet
# resource "aws_route_table" "dybench-vpn-rtb-private" {
#   vpc_id = aws_vpc.dybench.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.dybench-vpn-nat.id
#   }

#   route {
#     cidr_block                = "${var.cidr_prefix_vpn}.0.0/16"
#     vpc_peering_connection_id = aws_vpc_peering_connection.dybench-vpn.id
#   }
# }

# # Associate route table to private subnet
# resource "aws_route_table_association" "dybench-vpn-associate-r-s-private" {
#   subnet_id      = aws_subnet.dybench-vpn-sn-priv.id
#   route_table_id = aws_route_table.dybench-vpn-rtb-private.id
# }
