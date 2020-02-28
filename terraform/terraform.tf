provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh connections"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


data "template_file" "userdata_jenkins_worker_linux" {
  template = "${file("slave_setup.sh")}"
  vars = {
    JENKINS_IP  = var.JENKINS_IP
    JENKINS_USER = var.JENKINS_USER
    JENKINS_PASS = var.JENKINS_PASS
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  key_name      = "edu"

  user_data     = data.template_file.userdata_jenkins_worker_linux.rendered
  
  tags = {
    Name = "Terraform Slave"
  }
}

output "public_ip" {
 value = aws_instance.web.public_ip
}

output "private_ip" {
 value = aws_instance.web.private_ip
}
