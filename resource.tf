provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "Dev" {
    count = 1
    ami = "ami-0341d95f75f311023"
    instance_type = "t2.micro"
    tags = {
        Name = "Dev"
    }
}
