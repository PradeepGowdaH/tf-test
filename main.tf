## PUT TERRAFORM CLOUD BLOCK HERE!  ##

terraform {
  cloud {
    organization = "terraform_demo_course"

    workspaces {
      name = "tf-cloud-test"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.01"
    }
  }
}

# Variable blocks directly within the main.tf. No arguments necessary.
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}

# provider arguments call on the variables which then call on terraform.tfvars for the values.
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# Add .gitignore file in this directory with the terraform.tfvars

resource "aws_instance" "lesson_06" {
  ami           = "ami-00385a401487aefa4"
  instance_type = "t2.micro"
  key_name      = "new_aws_key_terraform"
  vpc_security_group_ids = [
    aws_security_group.sg_ssh.id,
    aws_security_group.sg_https.id,
    aws_security_group.sg_http.id
  ]

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.my_subnet.id

  tags = {
    Name = "TC-triggered-instance"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraformVPC"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "TerraformSubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "TerraformInternetGateway"
  }
}

# Create a route table
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "TerraformPublicRouteTable"
  }
}

# Create a route in the route table to direct traffic to the Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.my_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate the subnet with the route table (making it a public subnet)
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

resource "aws_security_group" "sg_ssh" {
  name        = "allow_ssh"
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow SSH inbound traffic"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "sg_https" {
  name        = "allow_https"
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow HTTPS inbound traffic"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "sg_http" {
  name        = "allow_http"
  vpc_id      = aws_vpc.my_vpc.id
  description = "Allow HTTP inbound traffic"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}