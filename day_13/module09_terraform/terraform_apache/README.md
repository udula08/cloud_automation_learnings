# Installing apache in ubuntu instance via terraform

## Prerequisites

- Install terraform. (https://developer.hashicorp.com/terraform/install)
- Configure AWS.
- Create a AWS s3 bucket as the backend.

## Setting Up

- Provider Block
```hcl
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
```
- Variable Block
```hcl
variable "user_data" {
  default = <<-EOF
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    sudo echo "Welcome to Terraform module" > /var/www/html/index.html
  EOF
}
```

- Data Block
```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-20.04-amd64-server-*"]
  }
}
```