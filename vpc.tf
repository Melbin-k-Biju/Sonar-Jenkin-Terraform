# Resource to create a VPC (Virtual Private Cloud)
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

# Resource to create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

## Resource to create a public subnet within the VPC
resource "aws_subnet" "public-subnet" {
  # VPC to associate the subnet with
  vpc_id = aws_vpc.vpc.id
  
  # CIDR block for the subnet's IP range
  cidr_block = "10.0.1.0/24"
  
  # Availability zone where the subnet will be located
  availability_zone = "ap-south-1a"
  
  # Automatically assign public IPs to instances launched in this subnet
  map_public_ip_on_launch = true

  # Tags for the subnet, with the name taken from a variable
  tags = {
    Name = var.subnet_name
  }
}

# Resource to create a Route Table for the VPC
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Destination for all Internet traffic
    gateway_id = aws_internet_gateway.igw.id  # Route traffic through the Internet Gateway
  }

  tags = {
    Name = var.route_table_name
  }
}
# Resource to associate the Route Table with the public subnet
resource "aws_route_table_association" "rt-association" {
  # Associate the route table with the public subnet
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public-subnet.id
}
# Resource to create a Security Group for controlling traffic to EC2 instances
resource "aws_security_group" "security-group" {
  # VPC to associate the security group with
  vpc_id = aws_vpc.vpc.id

  # Description of the security group (what it allows)
  description = "Allowing Jenkins, Sonarqube, SSH Access"
  ingress {
    description      = "Allow SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Jenkins traffic"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Sonarqube traffic"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow additional port"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to any destination
  }

  tags = {
    Name = var.security_group_name
  }
}
