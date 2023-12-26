provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}



locals {
  cluster_name   = "rc-cluster1"
  region = "us-east-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    cluster_name    = local.cluster_name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "19.21.0"
  cluster_name                   = local.cluster_name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]

    attach_cluster_primary_security_group = true

  }

  eks_managed_node_groups = {

    first = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"


      tags = {
        instanceFamily = "spot"
        nodeGroupType = "core"
      }
    }

    second = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      tags = {
        instanceFamily = "ondemand"
        nodeGroupType = "core"
      }
    }

    gpu = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      //ami_type = 
      instance_types = ["p3.2xlarge"]
      tags = {
        instanceFamily = "gpu"
        nodeGroupType = "gpu"
      }
    }
  }

  tags = local.tags

}

