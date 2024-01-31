resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az2"
  }
}

resource "aws_subnet" "private_subnet_az1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-az1a"
  }
}

resource "aws_subnet" "private_subnet_az1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-az1b"
  }
}

resource "aws_subnet" "private_subnet_az1c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-az1c"
  }
}

resource "aws_subnet" "private_subnet_az2a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-az2a"
  }
}

resource "aws_subnet" "private_subnet_az2b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-az2b"
  }
}

resource "aws_subnet" "private_subnet_az2c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-az2c"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_eip" "eip_nat_az1" {
  vpc = true
}


resource "aws_eip" "eip_nat_az2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_nat_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "nat-gateway-az1"
  }
}

resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_nat_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags = {
    Name = "nat-gateway-az2"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
}

resource "aws_route_table" "public_rt_az1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-rt-az1"
  }
}

resource "aws_route_table" "public_rt_az2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-rt-az2"
  }
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "private-rt-az1"
  }
}

resource "aws_route_table" "private_rt_az2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "private-rt-az2"
  }
}

resource "aws_route_table_association" "public_subnet_rt_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt_az1.id
}

resource "aws_route_table_association" "public_subnet_rt_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt_az2.id
}

resource "aws_route_table_association" "private_subnet_rt_az1a" {
  subnet_id      = aws_subnet.private_subnet_az1a.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_subnet_rt_az1b" {
  subnet_id      = aws_subnet.private_subnet_az1b.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_subnet_rt_az1c" {
  subnet_id      = aws_subnet.private_subnet_az1c.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_subnet_rt_az2a" {
  subnet_id      = aws_subnet.private_subnet_az2a.id
  route_table_id = aws_route_table.private_rt_az2.id
}

resource "aws_route_table_association" "private_subnet_rt_az2b" {
  subnet_id      = aws_subnet.private_subnet_az2b.id
  route_table_id = aws_route_table.private_rt_az2.id
}

resource "aws_route_table_association" "private_subnet_rt_az2c" {
  subnet_id      = aws_subnet.private_subnet_az2c.id
  route_table_id = aws_route_table.private_rt_az2.id
}



# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "Bastion"
  description = "Security group for SSH access from everywhere"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
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
    Name = "bastion-sg"
  }
}

# ELB-Web Security Group
resource "aws_security_group" "elb_web_sg" {
  name        = "ELB-Web"
  description = "Security group for HTTP access from everywhere"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
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

  tags = {
    Name = "elb-web-sg"
  }
}

# WebServer Security Group
resource "aws_security_group" "web_server_sg" {
  name        = "WebServer"
  description = "Security group for HTTP access from ELB-Web and SSH access from Bastion"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# ELB-App Security Group
resource "aws_security_group" "elb_app_sg" {
  name        = "ELB-App"
  description = "Security group for HTTP access from WebServer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-app-sg"
  }
}

# AppServer Security Group
resource "aws_security_group" "app_server_sg" {
  name        = "AppServer"
  description = "Security group for HTTP access from ELB-App and SSH access from Bastion"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_app_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-server-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "RDS"
  description = "Security group for PostgreSQL access from AppServer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_server_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

variable "key_name" {
  description = "SSH Key"
  type        = string
  default     = "projectKey"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name # Create key_name to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

resource "local_file" "private_key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "${path.module}/mykey.pem"
}
