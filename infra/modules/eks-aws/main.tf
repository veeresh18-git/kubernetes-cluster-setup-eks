module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_encryption_config = {
    resources = ["secrets"]
    provider_key_arn = var.kms_key_arn #store etcd tokens/keys in kms
  }

  cluster_addons = {
    coredns            = { 
        most_recent = true 
        } #in-cluster DNS server resolving service names.
    kube-proxy         = {
         most_recent = true
          } #handles Service VIP → Pod iptables/ipvs rules.
    vpc-cni            = {
         most_recent = true 
         } #assign ips to pods
    aws-ebs-csi-driver = {
         most_recent = true 
         } #dynamic provisioning of ebs volumes
  }

  eks_managed_node_groups = {
    ng-general = {

      ami_type = "AL2_x86_64"

      # cheaper instance
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

output "cluster_name" { 
    value = module.eks.cluster_name
     }
output "oidc_provider_arn" {
     value = module.eks.oidc_provider_arn 
     }
output "cluster_security_group_id" { 
    value = module.eks.cluster_security_group_id
     }
output "cluster_endpoint" { 
    value = module.eks.cluster_endpoint 
    }
output "cluster_ca" { 
    value = module.eks.cluster_certificate_authority_data 
    }