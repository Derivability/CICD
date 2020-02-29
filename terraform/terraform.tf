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

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http connections"

  ingress {
    from_port   = 80
    to_port     = 80
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
    AGENT_NAME = "Build_slave"
  }
}

data "template_file" "userdata_jenkins_stage_linux" {
  template = "${file("slave_setup.sh")}"
  vars = {
    JENKINS_IP  = var.JENKINS_IP
    JENKINS_USER = var.JENKINS_USER
    JENKINS_PASS = var.JENKINS_PASS
    AGENT_NAME = "Stage_slave"
  }
}

resource "aws_instance" "slave" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.allow_ssh.name]
  key_name      = "edu"

  user_data     = data.template_file.userdata_jenkins_worker_linux.rendered
  
  tags = {
    Name = "Terraform Slave"
  }
}

output "slave_public_ip" {
 value = aws_instance.slave.public_ip
}

output "slave_private_ip" {
 value = aws_instance.slave.private_ip
}

resource "aws_instance" "stage" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.allow_ssh.name,aws_security_group.allow_http.name]
  key_name      = "edu"

  user_data     = data.template_file.userdata_jenkins_stage_linux.rendered
  
  tags = {
    Name = "Terraform Stage"
  }
}

output "stage_public_ip" {
 value = aws_instance.stage.public_ip
}

output "stage_private_ip" {
 value = aws_instance.stage.private_ip
}
