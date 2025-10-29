provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "Myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Prod-Vpc"
  }
}

resource "aws_subnet" "pub_sub" {
  vpc_id                  = aws_vpc.Myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Prod_Pub_Sub"
  }

}

resource "aws_subnet" "pri_sub" {
  vpc_id                  = aws_vpc.Myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Prod_Pri_Sub"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Myvpc.id
  tags = {
    Name = "Prod-IGW"
  }
}

resource "aws_route_table" "Pub-RT" {
  vpc_id = aws_vpc.Myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}
resource "aws_route_table" "Pri-RT" {
  vpc_id = aws_vpc.Myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
  }
}
resource "aws_route_table_association" "Pub-sub-ass" {
  subnet_id      = aws_subnet.pub_sub.id
  route_table_id = aws_route_table.Pub-RT.id
}

resource "aws_route_table_association" "Pri-sub-ass" {
  subnet_id      = aws_subnet.pri_sub.id
  route_table_id = aws_route_table.Pri-RT.id
}

resource "aws_security_group" "Sg" {
  vpc_id = aws_vpc.Myvpc.id
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
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Nodeport"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Prod-Server" {
  for_each        = toset(["jenkins", "sonarQube", "Tomcat"])
  ami             = "ami-0360c520857e3138f"
  instance_type   = "t2.micro"
  key_name        = "New_Jenkins"
  vpc_security_group_ids = [aws_security_group.Sg.id]
  subnet_id = aws_subnet.pub_sub.id
  tags = {
    Name = "$echo.value"
  }
}
resource "aws_s3_bucket" "Prod-bucket" {
  bucket = "Prod_sai_Practice_Bucket"
  acl = "private"
}
