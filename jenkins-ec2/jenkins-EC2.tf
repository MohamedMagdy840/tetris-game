# AWS plugin  
provider "aws" {
  region = "eu-north-1"
}


resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-07c8c1b18ca66bb07"                 # "ami-080e1f13689e07408"
  instance_type               = "t3.medium"
  #subnet_id                   = aws_subnet.public_subnet_01.id
  key_name                    = "keypair"  
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
  }
 # Read the local install_jenkins.sh script and set it as user data
  user_data = file("jenkins.sh")

  tags = {
    Name = "jenkins_instance"

  }
  security_groups = [aws_security_group.jenkins_instance_sg.id]

}

resource "local_file" "public_ip_file" {
  filename = "jenkins_IP"
  content  = aws_instance.jenkins_instance.public_ip
}





resource "aws_security_group" "jenkins_instance_sg" {
  name        = "jenkins_instance_sg"
  description = "security group for jenkins instance"
  vpc_id      = aws_vpc.node_vpc.id



  # Define ingress rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  # Define egress rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}