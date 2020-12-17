# AWS.tf

#Creates a VPC with one primary CIDR range

#Creates an IGW and attaches it to the VPC

#Creates a subnet in the VPC

#Creates a public RT 

#Associates the subnet with the public RT 

#Creates a security group that only allows SSH inbound from anywhere, while allowing all traffic outbound

#Creates a public EC2 instance this infrastructure with an SSH key pair

#Outputs the Private IP of this public instance

#Outputs the Public_ip of this public instance

#Optionally, you may assign an EIP by uncommenting the aws_eip resource

#Note: Terraform will still output the Public IP, not EIP, on the first apply. 

#Note: If first apply is successful, you may run a second apply to simply display the EIP 

#Populate the terraform.tfvars variable file with your environment values to get everything deployed. Please pay attention to the comments. 
