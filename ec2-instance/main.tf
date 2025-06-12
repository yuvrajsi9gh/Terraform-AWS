terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
      region = "ap-south-1" 
    }

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] 

  filter {
    name   = "name"
    values = ["RHEL-9.*x86_64*"] 
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_subnet" "ap_south_1a" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0e593f00d0e881c67"]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-0e593f00d0e881c67"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


resource "aws_instance" "rhel_vm" {
  ami                    = data.aws_ami.rhel.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.ap_south_1a.id
  associate_public_ip_address = true
  key_name = "k8s"

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = "RHEL-Instance"
  }
}

