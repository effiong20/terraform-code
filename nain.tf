resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_eip" "eip-ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "nat-gw"
  }
  depends_on = [aws_eip.eip-ip]
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  count                   = length(var.public_cidr)
  cidr_block              = var.public_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[count.index]

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "privat_subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  count             = length(var.privat_cidr)
  cidr_block        = var.privat_cidr[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "privat_rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
}

resource "aws_route_table_association" "public_rt" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "privat_rt" {
  count          = length(var.privat_cidr)
  subnet_id      = aws_subnet.privat_subnet[count.index].id
  route_table_id = aws_route_table.privat_rt.id
}

resource "aws_instance" "my-server" {
  #  count = length(var.public_cidr)
  ami                         = "ami-0cae6d6fe6048ca2c"
  instance_type               = "t2.micro"
  key_name                    = "sample-key"
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  # user_data = file("file.sh")
  vpc_security_group_ids = [aws_security_group.Bastian-host-sg.id]

  tags = {
    Name = "HelloWorld"
  }
}
