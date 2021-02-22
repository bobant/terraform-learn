// Create Subnet
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

// Create Route Table
/*
resource "aws_route_table" "myapp-rtb" {
    vpc_id = var.vpc_id
*/    

// Use Default Route Table, you can use in resource names and tags: main instead default
resource "aws_default_route_table" "default-rtb" {
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    /*
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
    */     
    tags = {
        Name: "${var.env_prefix}-default-rtb"
    }
}

// Create Internet Gateway
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

// Use Route Table Association only for Non-Default Route Tables
/*
resource "aws_route_table_association" "rtb-subnet-association" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-rtb.id
}
*/