provider "aws" {
  region = "ap-southeast-2"  # Replace with your desired region
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0310483fb2b488153"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = "subnet-0312b60b435c51e16"  # Replace with your subnet ID

  vpc_security_group_ids = [aws_security_group.instance_sg.id]  # Use id instead of groupName

  tags = {
    Name = "TF-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              # This script will run when the instance starts
              apt-get update
              apt-get install -y docker.io
              usermod -aG docker ubuntu
              EOF
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg-"
  
  # Inbound rules to allow incoming traffic on specified ports
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
 ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
output "local_ip" {
  value = aws_instance.ec2_instance.private_ip
  }

}
