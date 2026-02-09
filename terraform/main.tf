resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = file("~/.ssh/devops-key.pub")
}

resource "aws_security_group" "web_sg" {
  name        = "static-web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "static_web" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.devops_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "static-web-server"
  }
}
