module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  # ----------------------------
  # Cluster basics
  # ----------------------------
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # ----------------------------
  # aws-auth MANAGEMENT (v19)
  # ----------------------------
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::262046511657:role/ksd-cicd-role"
      username = "github-actions"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::262046511657:user/ks-dev-user"
      username = "ks-dev-user"
      groups   = ["system:masters"]
    }
  ]

  # ----------------------------
  # Encryption (KMS)
  # ----------------------------
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

  # ----------------------------
  # Core EKS add-ons
  # ----------------------------
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

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # ----------------------------
  # Managed node group
  # ----------------------------
  eks_managed_node_groups = {
    ng-general = {
      name           = "general"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

      ami_type = "AL2_x86_64"

      labels = {
        workload = "general"
      }

      tags = var.tags
    }
  }

  tags = var.tags
}
