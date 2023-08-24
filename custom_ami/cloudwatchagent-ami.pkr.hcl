packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}


locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


data "amazon-ami" "amazon_linux" {
  region      = "us-east-1" 
  most_recent = true
  owners      = ["amazon"]
  filters = {
    name                = "amzn2-ami-hvm-*-x86_64-ebs"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
}


source "amazon-ebs" "basic" {
  shared_credentials_file = "/Users/gulnazzholshy/.aws/credentials"
  profile                 = "default"
  region                  = "us-east-1"

  ami_name      = "cw_agent_ami_${local.timestamp}"
  instance_type = "t2.micro"

  source_ami   = data.amazon-ami.amazon_linux.id
  ssh_username = "ec2-user"
}


build {
  sources = [
    "source.amazon-ebs.basic"
  ]

  provisioner "ansible" {
    command = "ansible-playbook"
    playbook_file = "./playbook/playbook.yml"
    user = "ec2-user"
  }
}


