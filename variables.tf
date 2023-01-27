
aws_availability_zones = "us-east-2"

# vpc_cidr_block = "10.0.0.0/16"
# private_subnets_cidr_blocks = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
# public_subnets_cidr_blocks = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
# cluster_name = "infotech_cluster"


#  local value "infotech_eks_cluster"
# variable "region" {
#     description = "us-east-2"
  
# }


# #how add different roles to k8s and map users and groups to the aws-auth config map

# variable "map_accounts" {
#     description = "Additional AWS account numbers to add to the aws-auth configmap."
#     type        = list(string)

#     default = [
#         "7777777777777777",
#         "8888888888888888",
#     ]  
# }


# variable "map_roles" {
#     description = "Additional IAM roles to add to the aws-auth configmap."
#     type        = list(object({
#         rolearn = string
#         username = string
#         groups = list(string)
#     }))

#     default = [
#         {
#         rolearn     = "arn:aws:iam::5555555555555:role/role1"
#         username    =   "role1"
#         groups = ["system:masters"]
#         },
#     ]  
# }