resource "aws_key_pair" "proxy_key_pair" {
  key_name   = "twmac"
  public_key = file(var.keyfile)
}

resource "aws_instance" "proxy" {
  ami                         = "ami-0257508f40836e6cf"
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.proxy_key_pair.key_name
  user_data                   = file("startup.sh")
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.proxy_sg.id]
  tags = {
    Name = "proxy"
  }
}

resource "aws_eip" "proxy_eip" {
  instance   = aws_instance.proxy.id
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_security_group" "proxy_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group-proxy"
  }
}

