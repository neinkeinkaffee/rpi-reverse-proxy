resource "aws_vpc" "vpc" {
  cidr_block = "10.0.1.0/24"
  tags {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "eu-central-1a"
  cidr_block = "10.0.1.0/26"
  tags {
    Name = "subnet-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "eu-central-1b"
  cidr_block = "10.0.1.64/26"
  tags {
    Name = "subnet-public-2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags {
    Name = "route-table-public"
  }
}

resource "aws_route_table_association" "route_subnet_1" {
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "route_subnet_2" {
  subnet_id = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}