provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_instance" "foo" {
  ami           = "ami-05fa00d4c63e32376" #
  instance_type = "t2.micro"
  tags = {
      Name = "TF-Instance"
  }
}
