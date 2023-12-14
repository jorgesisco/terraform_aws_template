# 1. VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.VPC
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# 3. Route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "etl_emails_ig_dev"
  }
}

# 4. Defining Subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone_id = var.AVAILABILITY_ZONE_ID
  map_public_ip_on_launch = true

  tags = {
    Name = var.INSTANCE_SUBNET
  }
}

# 5. Route table association
resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.subnet.id
   route_table_id = aws_route_table.route_table.id
 }

# 6. Creating Security Group
resource "aws_security_group" "security_group" {
  name        = "etl_emails_security_group_dev"
  description = "Security Group for the ETL-emails instance"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "etl_emails_security_group_dev"
  }
}

# 7. Creaing Network Interface
resource "aws_network_interface" "network_interface" {
  subnet_id = aws_subnet.subnet.id
  private_ips = ["10.0.1.50"]
  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "etl_emails_network_interface"
  }
}

# 8. Creating Elastic IP
resource "aws_eip" "elastic_ip" {
  network_interface = aws_network_interface.network_interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "etl_emails_elastic_public_ip"
  }
}

# 8.1. Associate Elastic IP with EC2
resource "aws_eip_association" "elastic_ip_association" {
    instance_id   = aws_instance.ec2.id
    allocation_id = aws_eip.elastic_ip.id
}

# 8.2. Create Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "etl_emails_key_dev"
  public_key = file("${path.module}/certs/etl_emails_key_dev.pub")
}

# 9. Create EC2 Instance
resource "aws_instance" "ec2" {
  ami           = "ami-09042b2f6d07d164a"
  instance_type = var.INSTANCE_TYPE
  availability_zone = var.AVAILABILITY_ZONE
  key_name = aws_key_pair.key_pair.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.network_interface.id
  }

   user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install git -y
              sudo apt install make -y
              sudo apt install nano -y
              EOF

  tags = {
    Name = var.INSTANCE_NAME
    Terraform = true
    Environment = var.ENV
  }

}

# 10. Create ECR Repository
resource "aws_ecr_repository" "repository" {
  for_each = toset(var.REPO_LIST)
  name = each.key
}


#TODO: 11. Create ECS Cluster