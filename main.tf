terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>4.0"
        }

    }

}

provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "infovpc" {
    cidr_block = "10.0.0.0/16"
    
    tags = {
        Name = "infovpc"
    }
}

/* create igw and attach it to infotech-vpc */ 

resource "aws_internet_gateway" "infoigw" {
    vpc_id = aws_vpc.infovpc.id

    tags = {
        Name = "infoigw"
    }
}
   
resource "aws-subnet" "private-us-east-2a" {
    vpc_id            = aws_vpc.infovpc.id
    cidr_block        = "10.0.0.0/19"
    availability_zone = "us-east-2a"

    tags = {
        "Name"                            = "private-us-east-2a"
        /* allow k8s to discover network where load bal is created */
        "kubernetes.io/role/internal-elb" = "1"
        /* volume name owned, bekz using for k8s,not shared with other */ 
        "kubernetes.io/cluster/infotech"  = "owned"
    }
}


resource "aws-subnet" "private-us-east-2b" {
    vpc_id            = aws_vpc.infovpc.id
    cidr_block        = "10.0.32.0/19"
    availability_zone = "us-east-2b"

    tags = {
        "Name"                            = "private-us-east-2b"
        /* allow k8s to discover network where load bal is created  */
        "kubernetes.io/role/internal-elb" = "1"
        /* volume name owned, bekz using for k8s,not shared with other */
        "kubernetes.io/cluster/infotech"  = "owned"
    }
}


resource "aws-subnet" "public-us-east-2a" {
    vpc_id            = aws_vpc.infovpc.id
    cidr_block        = "10.0.64.0/19"
    availability_zone = "us-east-2a"

    map_public_ip_on_launch = true

    tags = {
        "Name"                            = "public-us-east-2a" 
    /* "1" instructs k8s to create public load bal in that sub */
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/infotech"  = "owned"
    }
}


resource "aws-subnet" "public-us-east-2b" {
    vpc_id            = aws_vpc.infovpc.id
    cidr_block        = "10.0.96.0/19"
    availability_zone = "us-east-2b"
    map_public_ip_on_launch = true

    tags = {
        "Name"                            = "public-us-east-2b" 
    /* "1" instructs k8s to create public load bal in that sub */
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/infotech"  = "owned"
    }
}

/* nat gtw used in private subnet to allow services to connect to internet */
resource "aws_eip" "infoNat" {
    vpc = true

    tags = {
        Name = "infoNat"
    }
}

/* place the nat gateway in the public subnet which must have internal gateway as default route */
resource "aws_nat_gateway" "infoNat" {
    allocation_id = aws_eip.infoNat.id
    subnet_id = aws_subnet.public-us-east-2a.id

    tags = {
        Name = "infoNat"
    }

    depends_on = [aws_internet_gateway.infoigw]
}
  


 

/* create routing table and associate subnet with them */
             
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.infovpc.id

    route = [
        {
            cidr_block   = "0.0.0.0/0"
            nat_gateway_id = aws_nat_gateway.infoNat.id
        },  
    ]

    tags = {
        Name = "private"

    }
}   

/* public routing table  */

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.infovpc.id

    route = [
        {
            cidr_block   = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.infoigw.id
        },  
    ]

    tags = {
        Name = "public"
        
    }
}   

/* create table route associattion for all 4 subnets */

resource "aws_route_table_association" "private-us-east-2a" {
    subnet_id = aws_subnet.private-us-east-2a.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-2b" {
    subnet_id = aws_subnet.private-us-east-2b.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-2a" {
    subnet_id = aws_subnet.private-us-east-2a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-2b" {
    subnet_id = aws_subnet.private-us-east-2b.id
    route_table_id = aws_route_table.public.id
}


//create eks cluster with amazon eks cluster policy
     
resource "aws_iam_role" "infotech" {

    name = "eks-cluster-infotech"
      
    assume_role_policy = <<POLICY
    {
      "version": "2012-10-17",
       "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "Service": "eks.amazonaws.com"
              },
               "Action": "sts:AssumeRole"
               }
              ]
             }
             POLICY
}

resource "aws_iam_role_policy_attachment" "infotech-AmazonEKSClusterPolicy" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSclusterPolicy"
    role        = aws_iam_role.infotech.name
}

/* eks configuration */

resource "aws_eks_cluster" "infotech" {
    name = "infotech"
    role_arn = aws_iam_role.infotech.arn

    vpc_config {
      subnet_ids = [
        aws_subnet.private-us-east-2a.id,
        aws_subnet.private-us-east-2a.id,
        aws_subnet.public-us-east-2b.id,
        aws_subnet.public-us-east-2b.id
      ]
    }
    depends_on = [aws_iam_role_policy_attachment.infotech-AmazonEKSClusterPolicy]
}


