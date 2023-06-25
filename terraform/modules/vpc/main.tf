locals {
    name_prefix = "${var.env}-${var.app_name}"
}

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main" {
    cidr_block                  = var.cidr_block
    enable_dns_support    = true
    enable_dns_hostnames        = true
    
    tags = {
        Name = "${local.name_prefix}-vpc"
    }
}

# ---------------------------
# Subnet
# ---------------------------
resource "aws_subnet" "sn_pub_a" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
    availability_zone   = var.az_a

    tags = {
        Name = "${local.name_prefix}-sn-pub-a"
    }
}

resource "aws_subnet" "sn_pub_b" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
    availability_zone   = var.az_b

    tags = {
        Name = "${local.name_prefix}-sn-pub-c"
    }
}

resource "aws_subnet" "sn_priv_a" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
    availability_zone   = var.az_a

    tags = {
        Name = "${local.name_prefix}-sn-priv-a"
    }
}

resource "aws_subnet" "sn_priv_b" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = cidrsubnet(aws_vpc.main.cidr_block, 8, 3)
    availability_zone   = var.az_b

    tags = {
        Name = "${local.name_prefix}-sn-priv-c"
    }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-igw"
    }
}

# ---------------------------
# Route Table
# ---------------------------
resource "aws_route_table" "rt_pub" {
    vpc_id          = aws_vpc.main.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "${local.name_prefix}-rt-pub"
    }
}

resource "aws_route_table_association" "rt_associate_pub_a" {
    subnet_id       = aws_subnet.sn_pub_a.id
    route_table_id  = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rt_associate_pub_b" {
    subnet_id       = aws_subnet.sn_pub_b.id
    route_table_id  = aws_route_table.rt_pub.id
}

# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "sg_alb" {
    name        = "${local.name_prefix}-sg-alb"
    description = "sg for alb"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-sg-alb"
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_security_group" "sg_ecs" {
    name        = "${local.name_prefix}-sg-ecs"
    description = "sg for ecs"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-sg-ecs"
    }

    ingress {
        from_port                   = 32768
        to_port                     = 61000
        protocol                    = "tcp"
        security_groups    = [ aws_security_group.sg_alb.id ]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}