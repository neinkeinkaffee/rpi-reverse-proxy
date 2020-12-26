resource "aws_key_pair" "proxy_key_pair" {
  key_name   = "twmac"
  public_key = file(var.keyfile)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "proxy" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.proxy_key_pair.key_name
  user_data                   = data.template_file.init.rendered
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.proxy_sg.id]
  tags = {
    Name = "proxy"
  }
}

data "template_file" "init" {
  template = file("init.sh")

  vars = {
    DOMAIN = var.domain
    EMAIL = var.email
    CLOUDFLARE_API_TOKEN = var.cloudflare_api_token
    AGENT0=var.agent0
    AGENT1=var.agent1
    AGENT2=var.agent2
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

  ingress {
    from_port   = 655
    to_port     = 655
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 655
    to_port     = 655
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
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

output "proxy_eip" {
  value = aws_eip.proxy_eip.public_ip
}

output "proxy_public_ip" {
  value = aws_instance.proxy.public_ip
}
