resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "todo-app VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "todo-app IGW"
  }
}

resource "aws_route_table" "route_to_internet" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "todo-app route to Internet"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.route_to_internet.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.route_to_internet.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.route_to_internet.id
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id               = aws_vpc.example.id
  cidr_block           = "10.0.1.0/24"
  availability_zone_id = "use1-az1"

  tags = {
    Name = "public subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id               = aws_vpc.example.id
  cidr_block           = "10.0.2.0/24"
  availability_zone_id = "use1-az2"

  tags = {
    Name = "public subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id               = aws_vpc.example.id
  cidr_block           = "10.0.3.0/24"
  availability_zone_id = "use1-az3"

  tags = {
    Name = "public subnet 3"
  }
}

