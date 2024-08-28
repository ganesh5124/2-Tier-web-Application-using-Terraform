# Resource for aws VPC
resource "aws_vpc" "web-vpc" {
  cidr_block = "12.12.0.0/16"
  tags = {
    Name = "web-vpc"
  }
}

# Creating resource for public subnet 1a
resource "aws_subnet" "public-sn-1a" {
  depends_on              = [aws_vpc.web-vpc]
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "12.12.12.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-sn-1a"
  }
}

# # resource for public subnet 1b
resource "aws_subnet" "public-sn-1b" {
  depends_on              = [aws_vpc.web-vpc]
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "12.12.24.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sn-1b"
  }
}

# # resource for private subnet 1a
resource "aws_subnet" "private-sn-1a" {
  depends_on              = [aws_vpc.web-vpc]
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "12.12.36.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-sn-1a"
  }
}

# # resource for private subnet 1b
resource "aws_subnet" "private-sn-1b" {
  depends_on              = [aws_vpc.web-vpc]
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "12.12.48.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "private-sn-1b"
  }
}

# # Resource for aws VPC-IGW
resource "aws_internet_gateway" "web-igw" {
  depends_on = [aws_vpc.web-vpc]
  vpc_id     = aws_vpc.web-vpc.id
  tags = {
    Name = "web-igw"
  }
}

# # creating resource for 
resource "aws_route_table" "web-public-rt" {
  depends_on = [aws_vpc.web-vpc, aws_internet_gateway.web-igw]
  vpc_id     = aws_vpc.web-vpc.id
  tags = {
    Name = "web-public-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-igw.id
  }
}

resource "aws_route_table_association" "public-rt-association-a" {
  route_table_id = aws_route_table.web-public-rt.id
  subnet_id      = aws_subnet.public-sn-1a.id
}

resource "aws_route_table_association" "public-rt-association-b" {
  route_table_id = aws_route_table.web-public-rt.id
  subnet_id      = aws_subnet.public-sn-1b.id
}

resource "aws_route_table" "web-private-rt-a" {
  depends_on = [aws_vpc.web-vpc, aws_internet_gateway.web-igw]
  vpc_id     = aws_vpc.web-vpc.id
  tags = {
    Name = "web-private-rt-a"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.web-nat-a.id
  }
}

resource "aws_route_table" "web-private-rt-b" {
  depends_on = [aws_vpc.web-vpc, aws_internet_gateway.web-igw]
  vpc_id     = aws_vpc.web-vpc.id
  tags = {
    Name = "web-private-rt-b"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.web-nat-b.id
  }
}

resource "aws_route_table_association" "private-rt-association-a" {
  route_table_id = aws_route_table.web-private-rt-a.id
  subnet_id      = aws_subnet.private-sn-1a.id
}

resource "aws_route_table_association" "private-rt-association-b" {
  route_table_id = aws_route_table.web-private-rt-b.id
  subnet_id      = aws_subnet.private-sn-1b.id
}

resource "aws_eip" "web-eip-a" {
tags = {
  Name = "web-eip-a"
}
}

resource "aws_nat_gateway" "web-nat-a" {
  subnet_id = aws_subnet.public-sn-1a.id
  tags = {
    Name = "web-nat-a"
  }
  connectivity_type = "public"
  allocation_id     = aws_eip.web-eip-a.id
  
}

resource "aws_eip" "web-eip-b" {
tags = {
  Name = "web-eip-b"
}
}

resource "aws_nat_gateway" "web-nat-b" {
  subnet_id = aws_subnet.public-sn-1a.id
  tags = {
    Name = "web-nat-b"
  }
  connectivity_type = "public"
  allocation_id     = aws_eip.web-eip-b.id
  
}
