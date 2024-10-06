# VPC 
resource "aws_vpc" "vpc_main" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}_vpc"
  }
}

# VPC Subnet
resource "aws_subnet" "public" {
  count = var.node_count
  vpc_id            = aws_vpc.vpc_main.id 
  cidr_block        = var.cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}_public_${count.index}"
  }
}

# VPC Route Table
resource "aws_route_table" "public" {
  count = var.node_count
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "${var.project_name}_public_${count.index}_rt"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "public" {
  count = var.node_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# Add a route to the Route Table
resource "aws_route" "default_public_igw" {
  count = var.node_count
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_main.id
}

# Create an Internet Gateway 
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "${var.project_name}_igw"
  }
}