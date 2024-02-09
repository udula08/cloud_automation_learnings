terraform {
  required_providers {
    aws = {
      version = ">=5.34.0"
    }
  }
  backend "s3" {
    bucket = "udula_S3_tf"
    region = "eu-north-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-north-1"
}

variable "user_data" {
  default = <<-EOF
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo echo "Welcome to Terraform module" > /var/www/html/index.html
  EOF
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-20.04-amd64-server-*"]
  }
}

resource "aws_s3_bucket" "tf_s3" {
  bucket = "udula_S3_tf"

    tags = {
    Name        = "tf_bucket"
    }

}

resource "aws_security_group" "udula_tf_sec" {
  name        = "udula_tf_sec_group"
  description = "Security group for terraform homework"

  dynamic "ingress" {
    for_each = [22, 80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tf_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.udula_tf_sec_group.id]

  tags = {
    Name = "udula_tf"
  }

  user_data_base64 = base64encode(var.user_data)
}

output "ec2_instance_public_ip" {
  description = "The public IP address"
  value       = aws_instance.tf_instance.public_ip
}