terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}


#Public subnets for ALBs/NLBs; private subnets for worker nodes.
# NAT gateway allows nodes outbound access for pulls/updates. DNS support is required by EKS.