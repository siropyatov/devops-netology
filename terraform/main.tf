provider "aws" {
  region = "us-west-2"
  alias = "region"
  profile = "myprofile"
}

terraform {
  backend "s3" {
    bucket = "netology-test"
    region = "us-west-2"
    key = "terraform.tfstate"
    dynamodb_table = "terraform-locks"
    profile = "myprofile"
  }
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

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  #  instance_type = "t3.micro"
  instance_type = local.web_instance_type_map[terraform.workspace]
  count = local.web_instance_count_map[terraform.workspace]

  tags = {
    Name = "HelloWorld"
  }
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
    ignore_changes = [
      "tags"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  region        = data.aws_region.current.name
  web_instance_type_map = {
    stage = "t3.micro"
    test = "t3.micro"
  }
  web_instance_count_map = {
    test = 0
    stage = 1
  }
}