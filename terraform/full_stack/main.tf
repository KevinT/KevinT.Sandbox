terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_epl_access_key
  secret_key = var.aws_epl_secret_key
  region     = var.aws_region
}

resource "aws_vpc" "epl-dev-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "epl-dev-vpc"
  }

}

resource "aws_internet_gateway" "epl-dev-gateway-1" {
  vpc_id = aws_vpc.epl-dev-vpc.id

  tags = {
    Name = "epl-dev-gateway"
  }
}

resource "aws_route_table" "epl-dev-route-table-1" {
  vpc_id = aws_vpc.epl-dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.epl-dev-gateway-1.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.epl-dev-gateway-1.id
  }

  tags = {
    Name = "epl-dev-route-table"
  }
}

resource "aws_subnet" "epl-dev-subnet-frontend" {
  vpc_id            = aws_vpc.epl-dev-vpc.id
  cidr_block        = var.subnet_prefix_frontend
  availability_zone = "us-east-1a"

  tags = {
    Name = "epl-dev-subnet-frontent"
  }

}

resource "aws_subnet" "epl-dev-subnet-backend" {
  vpc_id            = aws_vpc.epl-dev-vpc.id
  cidr_block        = var.subnet_prefix_backend
  availability_zone = "us-east-1a"

  tags = {
    Name = "epl-dev-subnet-backend"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.epl-dev-subnet-frontend.id
  route_table_id = aws_route_table.epl-dev-route-table-1.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.epl-dev-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web"
  }
}

resource "aws_network_interface" "epl-dev-web-server-nic" {
  subnet_id       = aws_subnet.epl-dev-subnet-frontend.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.epl-dev-web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.epl-dev-gateway-1
  ]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

resource "aws_instance" "epl-dev-web-server" {
  ami               = "ami-09e67e426f25ce0d7"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "epl-dev-main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.epl-dev-web-server-nic.id
  }

  user_data = "${file("install_apache.sh")}"

  tags = {
    Name = "epl-dev-web-server"
  }
}

resource "aws_db_subnet_group" "epl-dev-db-subnet-group" {
  name       = "main"
  subnet_ids = [aws_subnet.epl-dev-subnet-frontend.id, aws_subnet.epl-dev-subnet-backend.id]

  tags = {
    Name = "EPL Dev DB subnet group"
  }
}

resource "aws_db_instance" "epl-dev-rds" {
  allocated_storage    = 100
  db_subnet_group_name = "main"
  engine               = "postgres"
  engine_version       = "11.5"
  identifier           = "epl-dev-rds"
  instance_class       = "db.m5.large"
  password             = "password"
  skip_final_snapshot  = true
  storage_encrypted    = true
  username             = "postgres"
}