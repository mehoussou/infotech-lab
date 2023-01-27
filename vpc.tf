module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.14.2"

    name                = "infotech_vpc"

    cidr                = "10.0.0.0/16"
    azs                 = slice(data.aws_availability_zones.available.names, 0, 3)
    
# defined 3 privates and 3 public subnets
    private_subnets      = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
    public_subnets      = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]


    enable_nat_gateway  = true
    single_nat_gateway  = true
    enable_dns_hostnames= true

    private_subnet_tags = {
        # "kubernetes.io/cluster/${local.cluster_name}" = "shared"
         "kubernetes.io/cluster/${local.cluster_name}" = "shared"

        "kubernetes.io/role/internal-elb"           = "1"

    }

}