provider "aws" {
    profile = "my-ops"
    region  = "eu-central-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

// Create Route Table
/*
resource "aws_route_table" "myapp-rtb" {
    vpc_id = aws_vpc.myapp-vpc.id
*/    

// Use Default Route Table, you can use in resource names and tags: main instead default
resource "aws_default_route_table" "default-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

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

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

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

// Create Security Group
/*
resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id
*/    

// Use Default Security Group
resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id    

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]     
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []     
    }
   
    /*
    tags = {
        Name: "${var.env_prefix}-sg"
    }
    */
    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id    
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip   
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}
 
resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.availability_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    /*
    user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2-user
                    docker run -p 8080:80 nginx
                EOF                    
    */
    
    # user_data = file("entry-script.sh")

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_location)
    }

    provisioner "file" {
        source = "entry-script.sh"
        destination = "/home/ec2-user/entry-script-on-ec2.sh"
    }

    provisioner "remote-exec" {
        /*
        inline = [
            "export ENV=dev",
            "mkdir newdir"
        ]
        */
        script = file("entry-script-on-ec2.sh")
    }

    provisioner "local-exec" {
        command = "echo ${self.public_ip} > output.txt"
    }

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

/*
output "myapp-vpc-id" {
    value = aws_vpc.myapp-vpc.id
}

output "myapp-subnet-1-id" {
    value = aws_subnet.myapp-subnet-1.id
}
*/