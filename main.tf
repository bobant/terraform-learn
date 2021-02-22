provider "aws" {
    profile = "my-ops"
    region  = "eu-central-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id    
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_id = module.myapp-subnet.subnet.id
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    image_name = var.image_name
    instance_type = var.instance_type
    my_ip = var.my_ip
    public_key_location = var.public_key_location
    private_key_location = var.private_key_location
}

/*
output "myapp-vpc-id" {
    value = aws_vpc.myapp-vpc.id
}

output "myapp-subnet-1-id" {
    value = aws_subnet.myapp-subnet-1.id
}
*/