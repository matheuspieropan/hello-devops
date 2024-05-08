provider "aws" {
  region = var.aws_region 
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = "hello"
  cluster_version = "1.29"

  enable_cluster_creator_admin_permissions = true
  subnet_ids                               = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.small"]
    }
  }
}