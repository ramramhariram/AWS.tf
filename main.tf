#Creates a VPC with one primary CIDR range
resource "aws_vpc" "terra_vpc" {
  cidr_block = var.vpc_cidr_block 

  tags = {
    Name = "tf-vpc"
  }
}
#Creates an IGW and attaches it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "tf-vpc-igw"
  }
}

#Creates a subnet in the VPC
resource "aws_subnet" "terra_subnet" {
  vpc_id            = aws_vpc.terra_vpc.id
  cidr_block        = var.pubsubnet1_cidr_block
  availability_zone = var.pubsubnet1_availability_zone

  tags = {
    Name = "tf-vpc-pubsub1"
  }
}

#Creates a public RT 
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.terra_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "tf-vpc-pubrt"
  }
}
#Associates the subnet with the public RT 
resource "aws_route_table_association" "publicassociation" {
  subnet_id      = aws_subnet.terra_subnet.id
  route_table_id = aws_route_table.publicrt.id
}

#Creates a security group that only allows SSH inbound from anywhere, while allowing all traffic outbound
resource "aws_security_group" "allow_all_ssh" {
  name        = "allow_all_SSH"
  description = "Allow all SSH traffic inbound"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    description = "all ssh from world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

#Creates a public EC2 instance this infrastructure with an SSH key pair
resource "aws_instance" "terra_ec2" {
  ami           = var.ami 
  instance_type = var.instance_type
#Optional input to turn on termination protection: 
  #disable_api_termination = true
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_all_ssh.id]
  subnet_id = aws_subnet.terra_subnet.id
  associate_public_ip_address = true 
  tags = {
    Name = "tf-vpc-pub-instance1"
  }
 #optional input for lower CPU instances: 
  #credit_specification {
      #cpu_credits = "unlimited"
  # }
  depends_on = [aws_internet_gateway.igw]
}

#Outputs the Private IP of this public instance
output "instance_ip_addr_private" {
  value = aws_instance.terra_ec2.private_ip 
}

#Outputs the Public_ip of this public instance
output "instance_ip_addr_public" {
  value = aws_instance.terra_ec2.public_ip
}

#Optionally, you may assign an EIP by uncommenting the aws_eip resource below
#Note: Terraform will still output the Public IP, not EIP, on the first apply. 
#Note: If first apply is successful, you may run a second apply to simply display the EIP 

/*
#Allocates and EIP and attaches to this public instance
resource "aws_eip" "terra_eip" {
  vpc = true
  instance   = aws_instance.terra_ec2.id
  depends_on = [aws_internet_gateway.igw]
}
*/
