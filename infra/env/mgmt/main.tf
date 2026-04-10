########################################
# Locals
########################################

locals {
  azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

########################################
# KMS key for EKS secrets encryption
########################################

resource "aws_kms_key" "eks_secrets" {
  description             = "EKS secrets encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = var.tags
}

########################################
# Networking (VPC)
########################################

module "network" {
  source          = "../../modules/network-aws"
  name            = "ksd-mgmt-vpc"
  cidr            = "10.10.0.0/16"
  azs             = local.azs
  public_subnets  = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  private_subnets = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]
  tags            = var.tags
}

########################################
# EKS Cluster
########################################

module "eks" {
  source          = "../../modules/eks-aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
  kms_key_arn     = aws_kms_key.eks_secrets.arn
  tags            = var.tags
}

########################################
# IAM Policies (IRSA)
########################################

locals {
  policy_cluster_autoscaler = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes"
      ],
      Resource = "*"
    }]
  })

  policy_external_dns = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })

  policy_alb = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "elasticloadbalancing:*",
        "ec2:Describe*",
        "iam:CreateServiceLinkedRole",
        "cognito-idp:DescribeUserPoolClient",
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL"
      ],
      Resource = "*"
    }]
  })

  # ✅ EBS CSI Driver policy
  policy_ebs_csi = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications"
      ]
      Resource = "*"
    }]
  })
}

########################################
# IRSA Roles
########################################

# ALB Controller
module "irsa_alb" {
  source             = "../../modules/irsa-aws"
  role_name          = "${var.cluster_name}-alb-controller"
  oidc_provider_arn  = module.eks.oidc_provider_arn
  sa_namespace       = "kube-system"
  sa_name            = "aws-load-balancer-controller"
  inline_policy_json = local.policy_alb
  tags               = var.tags
}

# External DNS
module "irsa_external_dns" {
  source             = "../../modules/irsa-aws"
  role_name          = "${var.cluster_name}-external-dns"
  oidc_provider_arn  = module.eks.oidc_provider_arn
  sa_namespace       = "kube-system"
  sa_name            = "external-dns"
  inline_policy_json = local.policy_external_dns
  tags               = var.tags
}

# Cluster Autoscaler
module "irsa_ca" {
  source             = "../../modules/irsa-aws"
  role_name          = "${var.cluster_name}-cluster-autoscaler"
  oidc_provider_arn  = module.eks.oidc_provider_arn
  sa_namespace       = "kube-system"
  sa_name            = "cluster-autoscaler"
  inline_policy_json = local.policy_cluster_autoscaler
  tags               = var.tags
}

# ✅ EBS CSI Driver IRSA
# module "irsa_ebs_csi" {
#   source             = "../../modules/irsa-aws"
#   role_name          = "${var.cluster_name}-ebs-csi"
#   oidc_provider_arn  = module.eks.oidc_provider_arn
#   sa_namespace       = "kube-system"
#   sa_name            = "ebs-csi-controller-sa"
#   inline_policy_json = local.policy_ebs_csi
#   tags               = var.tags
# }

########################################
# EKS Add-ons
########################################

# # ✅ EBS CSI Driver Addon
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   service_account_role_arn = module.irsa_ebs_csi.role_arn

#   depends_on = [
#     module.irsa_ebs_csi
#   ]
# }

########################################
# Helm-based Add-ons
########################################

module "addons" {
  source                    = "../../modules/addons-helm"
  cluster_name              = module.eks.cluster_name
  aws_region                = var.aws_region
  vpc_id                    = module.network.vpc_id
  alb_irsa_role_arn         = module.irsa_alb.role_arn
  externaldns_irsa_role_arn = module.irsa_external_dns.role_arn
  ca_irsa_role_arn          = module.irsa_ca.role_arn
  domain_filters            = ["example.com"]
}