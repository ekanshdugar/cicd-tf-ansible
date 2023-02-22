terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.44.0"
    }
  }
}


variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}


provider "aws" {
  region = "us-east-2"
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
}

resource "aws_iam_role" "tf-role" {
  name = "tf-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role" "ansible-role" {
  name = "ansible-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_instance_profile" "tf-profile" {
   name = "tf-instance-profile"
   role = aws_iam_role.tf-role.name
 }

resource "aws_iam_instance_profile" "ansible-profile" {
   name = "ansible-instance-profile"
   role = aws_iam_role.ansible-role.name
 }


resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh_"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}



resource "aws_instance" "terraform-ec2" {
  ami                  = "ami-0cc87e5027adcdca8"
  instance_type        = "t2.micro"
  key_name             = "tf-ansible-key"
  iam_instance_profile = aws_iam_instance_profile.tf-profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}


resource "aws_instance" "ansible-ec2" {
  ami                  = "ami-0cc87e5027adcdca8"
  instance_type        = "t2.micro"
  key_name             = "tf-ansible-key"
  iam_instance_profile = aws_iam_instance_profile.ansible-profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

#     connection {
#         type        = "ssh"
#         user        = "ec2-user"
#         host        = aws_instance.ansible-ec2.public_ip
#    }

#     provisioner "remote-exec" {
#         inline = [
#        "sudo amazon-linux-extras install -y ansible2"
#      ]
#    }
}