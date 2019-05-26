resource "aws_instance" "proxy" {
  ami = "ami-0f0debf49705e047c"
  subnet_id = "${aws_subnet.public_subnet_1.id}"
  associate_public_ip_address = true
  key_name = "twmac"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.proxy_sg.id}"]
  tags = {
    Name = "proxy"
  }
}

resource "aws_eip" "proxy_eip" {
  instance = "${aws_instance.proxy.id}"
  vpc      = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_security_group" "proxy_sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "security-group-proxy"
  }
}