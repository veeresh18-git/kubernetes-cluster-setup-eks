module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # ----------------------------
  # Cluster Basics
  # ----------------------------
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Grants admin ONLY to the identity running terraform apply
  enable_cluster_creator_admin_permissions = true

  # ----------------------------
  # ACCESS MANAGEMENT (v20+)
  # ----------------------------
  access_entries = {
    github_actions = {
      principal_arn     = "arn:aws:iam::262046511657:role/ksd-cicd-role"
      kubernetes_groups = ["system:masters"]
    }

    ks_dev_user = {
      principal_arn     = "arn:aws:iam::262046511657:user/ks-dev-user"
      kubernetes_groups = ["system:masters"]
    }
  }

  # ----------------------------
  # Encryption (etcd secrets)
  # ----------------------------
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

  # ----------------------------
  # EKS Add-ons
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
  # Managed Node Group
  # ----------------------------
  eks_managed_node_groups = {
    ng-general = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 3

      labels = {
        workload = "general"
      }

      tags = var.tags
    }
  }

  tags = var.tags
}
