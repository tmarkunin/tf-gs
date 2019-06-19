
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "ec2-user"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = "us-west-1"
}

##################################################################################
# RESOURCES
##################################################################################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "nginx" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"
  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key_path)}"
    host = "self.public_ip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "http://${aws_instance.nginx.public_dns}"
}