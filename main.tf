resource "aws_vpc" "hrs_vpc" {
  cidr_block = "10.66.0.0/16"

  tags = {
    Name = "tf-hrs-1-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hrs_vpc.id

  tags = {
    Name = "IGW-terra"
  }
}

resource "aws_subnet" "hrs_subnet" {
  vpc_id            = aws_vpc.hrs_vpc.id
  cidr_block        = "10.66.0.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-hrs-1-sub-1"
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.hrs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "publicRT"
  }
}

resource "aws_route_table_association" "publicassociation" {
  subnet_id      = aws_subnet.hrs_subnet.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_security_group" "allow_all_ssh" {
  name        = "allow_all_SSH_terra"
  description = "Allow all SSH traffic inbound for terra"
  vpc_id      = aws_vpc.hrs_vpc.id

  ingress {
    description = "all ssh from world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [aws_vpc.hrs_vpc.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_all_terra"
  }
}

resource "aws_instance" "firstterraec2" {
  ami           = "ami-0885b1f6bd170450c" # us-east-1
  instance_type = "t2.micro"
  #disable_api_termination = true
  key_name = "terrraec2"
  vpc_security_group_ids = [aws_security_group.allow_all_ssh.id]
  subnet_id = aws_subnet.hrs_subnet.id
  associate_public_ip_address = true 
  tags = {
    Name = "firstterrainstance"
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  depends_on = [aws_internet_gateway.igw]
}

