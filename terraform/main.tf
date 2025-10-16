terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" { region = var.region }

# --- AMI: latest Ubuntu 22.04 LTS (Jammy) ---
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Networking: Minimal public VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security group: allow SSH (22) and HTTP (80) ---
resource "aws_security_group" "web" {
  name        = "${var.project}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.project}-sg" }
}

# --- Generate an SSH keypair (ED25519) ---
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

# Upload PUBLIC key to AWS
resource "aws_key_pair" "admin" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save PRIVATE key locally so you can SSH
resource "local_file" "private_key_pem" {
  filename        = "${path.module}/keys/${var.project}"
  content         = tls_private_key.ssh.private_key_openssh
  file_permission = "0600"
}

# --- EC2 instance ---
resource "aws_instance" "node_host" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.admin.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  # Install Python for Ansible
  user_data = <<-EOF
              #!/usr/bin/env bash
              set -eux
              export DEBIAN_FRONTEND=noninteractive
              apt-get update -y
              apt-get install -y python3 python3-apt
              EOF

  tags = { Name = "${var.project}-node-host" }
}

# Optional: Elastic IP for stable address
resource "aws_eip" "node_eip" {
  count    = var.create_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.node_host.id
  tags     = { Name = "${var.project}-eip" }
}
