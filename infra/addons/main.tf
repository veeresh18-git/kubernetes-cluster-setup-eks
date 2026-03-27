module "addons" {
  source = "../../modules/addons-helm"

  cluster_name              = var.cluster_name
  aws_region                = var.aws_region
  vpc_id                    = var.vpc_id
  alb_irsa_role_arn         = var.alb_irsa_role_arn
  externaldns_irsa_role_arn = var.externaldns_irsa_role_arn
  ca_irsa_role_arn          = var.ca_irsa_role_arn
  domain_filters            = ["example.com"]
}