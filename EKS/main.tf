#Vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks_cluster_vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets


  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1

  }
  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/private_elb"       = 1

  }
}

#EKS

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  name    = "my-eks-cluster"
  version = "~> 21.0" # Use a modern version. Adjust as needed.
  # ... other inputs
  kubernetes_version     = "1.29"
  endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = var.instance_types
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
