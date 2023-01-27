module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    version         = "18.26.6"

    cluster_name    = local.cluster_name
    cluster_version = "1.22"

    #don't want the node to be public, so will attach it to private subnets
    vpc_id           = module.vpc.vpc_id
    subnet_ids       = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"

        attach_cluster_primary_security_group = true

        create_security_group = false
    }

    eks_managed_node_groups = {
        one = {
            name = "node-group-1"
            instance_types = ["t2.micro"]

            min_size        = 1
            max_size        = 3
            desired_size    = 2

            additional_userdata =   "echo foo bar"

            vpc_security_group_ids = [
                aws_security_group.infotech_node_group_one.id
            ]
        }

        two = {
            name = "node-group-2"

            instance_types =    ["t2.micro"]
            min_size        = 1
            max_size        = 3
            desired_size    = 2

            additional_userdata =   "echo foo bar"

            vpc_security_group_ids = [
                aws_security_group.infotech_node_group_two.id
            ]
        }

    }

}


