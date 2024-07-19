terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.1"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "tls_private_key" "remote_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "remote_key" {
  key_name   = "remote_key"
  public_key = tls_private_key.remote_key.public_key_openssh
}

// Save the private key
resource "local_file" "remote_key" {
  content  = tls_private_key.remote_key.private_key_pem
  filename = "remote_key.pem"
}


## This is the resource block for creating Ec2 instance
resource "aws_instance" "myec2" {
    ami = "ami-0103953a003440c37"
    count = 2
    key_name = aws_key_pair.remote_key.key_name
    associate_public_ip_address = true
    instance_type = "t2.micro"
    tags = {
        Name = "myec2-instance"
    }
}