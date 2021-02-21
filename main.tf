provider "aws" {
    profile = "my-ops"
    region  = "eu-central-1"
    //access_key = "..."
    //secret_key = "..."
}

/*
variable "environment" {
    description = "deployment environment"
}

variable "vpc_cidr_block" {
    description = "vpc cidr block"
    //default = "10.0.0.0/16"
    }

variable "subnet_cidr_block" {
    description = "subnet cidr block"
    //default = "10.0.10.0/16"
}
*/

variable "cidr_blocks" {
    description = "cidr blocks for vpc and subnets"
    type = list(object({
        cidr_block = string 
        name       = string
    }))
}

resource "aws_vpc" "development-vpc" {
    //cidr_block = "10.0.0.0/16"
    //cidr_block = var.vpc_cidr_block
    cidr_block = var.cidr_blocks[0].cidr_block
        /*
    tags = {
        Name: var.environment
    }
    */
    tags = {
        Name: var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    //cidr_block = "10.0.10.0/24"
    //cidr_block = var.subnet_cidr_block
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "eu-central-1a"
    /*
    tags = {
        Name: "subnet-1-dev"
    }
    */
    tags = {
        Name: var.cidr_blocks[1].name
    }
}

data "aws_vpc" "existing-vpc" {
    default = true    
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing-vpc.id
    //cidr_block = "172.31.48.0/20"
    cidr_block = var.cidr_blocks[2].cidr_block
    availability_zone = "eu-central-1a"
    /*
    tags = {
        Name: "subnet-2-default"
    }
    */
    tags = {
        Name: var.cidr_blocks[2].name
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-1-id" {
    value = aws_subnet.dev-subnet-1.id
}