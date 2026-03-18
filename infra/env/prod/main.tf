locals {
  azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
# KMS for secret encryption
resource "aws_kms_key" "eks_secrets" {
  description             = "EKS secrets encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags = var.tags
}
module "network" {
  source          = "../../modules/network-aws"
  name            = "ksd-vpc"
  cidr            = "10.20.0.0/16"
  azs             = local.azs
  public_subnets  = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
  private_subnets = ["10.20.128.0/20","10.20.144.0/20","10.20.160.0/20"]
  tags            = var.tags
}
module "eks" {
  source          = "../../modules/eks-aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
  kms_key_arn     = aws_kms_key.eks_secrets.arn
  tags            = var.tags
}
# IRSA roles
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
# Policies from earlier locals
locals {
  policy_cluster_autoscaler = jsonencode({
    Version="2012-10-17",
    Statement=[{
      Effect="Allow",
      Action=["autoscaling:DescribeAutoScalingGroups","autoscaling:DescribeAutoScalingInstances",
              "autoscaling:DescribeLaunchConfigurations","autoscaling:DescribeTags",
              "ec2:DescribeLaunchTemplateVersions","autoscaling:SetDesiredCapacity",
              "autoscaling:TerminateInstanceInAutoScalingGroup","ec2:DescribeImages","ec2:DescribeInstanceTypes"],
      Resource=""
    }]
  })
  policy_external_dns = jsonencode({
    Version="2012-10-17",
    Statement=[
      {Effect="Allow", Action=["route53:ListHostedZones","route53:ListResourceRecordSets"], Resource=""},
      {Effect="Allow", Action=["route53:ChangeResourceRecordSets"], Resource="arn:aws:route53:::hostedzone/REPLACE_WITH_ZONEID"}
    ]
  })
  policy_alb = jsonencode({
    Version="2012-10-17",
    Statement=[{Effect="Allow", Action=["elasticloadbalancing:","ec2:Describe","iam:CreateServiceLinkedRole","cognito-idp:DescribeUserPoolClient","waf-regional:GetWebACLForResource","waf-regional:GetWebACL"], Resource="*"}]
  })
}
# Helm add-ons
module "addons" {
  source                   = "../../modules/addons-helm"
  cluster_name             = module.eks.cluster_name
  aws_region               = var.aws_region
  vpc_id                   = module.network.vpc_id
  alb_irsa_role_arn        = module.irsa_alb.role_arn
  externaldns_irsa_role_arn= module.irsa_external_dns.role_arn
  ca_irsa_role_arn         = module.irsa_ca.role_arn
  domain_filters           = ["example.com"] # change to your zone(s)
}
# Enable control plane logs to CloudWatch (auditable)