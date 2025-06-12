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

# Create 2 EC2 Instances
resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.rhel.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.ap_south_1a.id
  key_name      = "k8s"

  associate_public_ip_address = true

  tags = {
    Name = "Web-${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from instance ${count.index}" > /var/www/html/index.html
              EOF
}

# Fetch RHEL AMI
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

# Subnet (ap-south-1a)
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

# Subnet (ap-south-1b)
data "aws_subnet" "ap_south_1b" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0e593f00d0e881c67"]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1b"]
  }
}


# Security Group
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = "vpc-0e593f00d0e881c67"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name             = "app-tg"
  port             = 80
  protocol         = "HTTP"
  target_type      = "instance"
  vpc_id           = "vpc-0e593f00d0e881c67"
  ip_address_type  = "ipv4"
  protocol_version = "HTTP1"

  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    data.aws_subnet.ap_south_1a.id,
    data.aws_subnet.ap_south_1b.id
  ]

  enable_deletion_protection = false
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Register Targets
resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}


/*
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

# Create 2 EC2 Instances
resource "aws_instance" "web-server" {
  count         = 2
  ami           = "ami-0038df39db13a87e2" 
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.ap_south_1a.id
  key_name      = "k8s"

  associate_public_ip_address = true

  tags = {
    Name = "Web-${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from instance ${count.index}" > /var/www/html/index.html
              EOF
}

# Subnet (ap-south-1a)
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

# Security Group
resource "aws_security_group" "alb_sg" {
  name   = "alb_sg"
  vpc_id = "vpc-0e593f00d0e881c67"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create an Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [data.aws_subnet.ap_south_1a.id]

  enable_deletion_protection = false

  tags = {
    Name = "Web-ALB"
  }
}   
# Create a Target Group for the ALB     
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0e593f00d0e881c67"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Web-TG"
  }
}
# Create a Listener for the ALB
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
# Register EC2 Instances with the Target Group  
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count               = 2
  target_group_arn   = aws_lb_target_group.web_tg.arn
  target_id          = aws_instance.web[count.index].id
  port               = 80

  depends_on = [aws_lb_listener.web_listener]
}
# Output the ALB DNS Name
output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}
# Output the public IPs of the EC2 Instances
output "instance_public_ips" {
  value = aws_instance.web[*].public_ip
}
*/
