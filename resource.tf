provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "Dev" {
    count = 1
    ami = "ami-07860a2d7eb515d9a"
    instance_type = "t2.micro"
    tags = {
        Name = "Dev"
    }
}
