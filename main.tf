terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

# terraform {

#   backend "s3" {
#     bucket = "primusterra-app"
#     key = "myapp/state.tfstate"
#     region = "us-east-2"
#   }
# }


provider "aws" {
  region = "us-east-2"
}


variable "aws_availability_zones" {}
variable "cluster_name" {}



resource "aws_vpc" "infotech_vpc" {
    cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "infotech_subnet-1" {
    vpc_id = aws_vpc.infotech_vpc
    cidr_block = "10.0.0.0/24"
  
}

resource "aws_instance" "web_server" {
    ami = "ami-0cea098ed2ac54925"
    instance_type = "t2.micro"
    tags = {
      Name = "web_server"
    }
}






# data "aws_eks_cluster" "cluster" {
#     name = module.eks.cluster_id

# }

# data "aws_eks_cluster_auth" "cluster" {
#     name = module.eks.cluster_id

# }

# data "aws_availability_zones" "available" {

# }


# create aws security group for infotech worker nodes

# resource "aws_security_group" "infotech_worker_group_mgmt-sg" {
#     name_prefix = "infotech_worker_group_mngt-sg"
#     vpc_id = module.vpc.vpc_id
  
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = [var.my_ip]
#   }

# resource "aws_security_group" "infotech_All_worker_mgmt-sg" {
#     name_prefix = "infotech_All_worker_mgmt-sg"
#     vpc_id = module.vpc.vpc_id

#     ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"

#     cidr_blocks = [var.my_ip]
#   }


# create vpc module, name of infotech vpc and addresses rang

# module "vpc" {
#     source = "terraform-aws-modules/vpc/aws"
#     version = "2.6.0"

#     name                = "infotech-vpc"
#     cidr                = "10.0.0.0/16"
#     azs                 = data.aws_availability_zones.available.names
# # defined 3 privates and 3 public subnets
#     private_subnet      = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
#     public_subnets      = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]

#     enable_nat_gateway  = true
#     single_nat_gateway  = true
#     enable_dns_hostnames= true

#     private_subnet_tags = {
#         "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#         "kubernetes.io/role/internal-elb"           = "1"

#     }

# }

# creating eks cluster for infotech

# module "eks" {
#     source          = "terraform-aws-modules/eks/aws"
#     version         = "12.2.0"
#     cluster_name    = var.cluster_name
#     cluster_version = "1.17"
#     #don,t want the node to be public, so will attach it to private subnets
#     subnets         = module.vpc.private_subnets
#     #for how long you want the cluster to create
#     cluster_create_timeout = "1h"
#     #allow private access endpoint to connect to k8s and join the cluster automatically
#     cluster_endpoint_private_access = true
#     vpc_id          =    module.vpc_id

#     worker_groups = [
#     {               
#             name            =       "worker_group-1"
#             instance_type   =       "t2.small"
#             additional_userdata =   "echo foo bar"
#             asg_desired_capacity    =   1
#             additional_security_group_ids   =   [aws_security_group.infotech_All_worker_mgmt-sg.id]    
#     },
#     ]
#     #add additional security group to allow other users to have nodes access not only admin
#     worker_additional_security_group_ids = [aws_security_group.infotech_All_worker_mgmt-sg.id]
#     map_roles           = var.map_roles
#     map_users           = var.map_users
#     map_accounts        = var.map_accounts
# }









#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.env_prefix}-default-sg"
#   }

