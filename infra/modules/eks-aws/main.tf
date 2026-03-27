module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  # API access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Give creator (CI/CD role) admin automatically
  enable_cluster_creator_admin_permissions = true

  # Modern access control (NO aws-auth)
  access_entries = {
    cicd-role = {
      principal_arn = "arn:aws:iam::262046511657:role/ksd-cicd-role"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    dev-user = {
      principal_arn = "arn:aws:iam::262046511657:user/ks-dev-user"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Encryption (KMS)
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

  # Core addons
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

  # Node group
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
