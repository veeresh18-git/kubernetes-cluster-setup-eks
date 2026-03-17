# metrics-server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
  values = [yamlencode({
    args = ["--kubelet-insecure-tls"] # consider removing with proper TLS
  })]
}
# aws-load-balancer-controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"
  values = [yamlencode({
    clusterName        = var.cluster_name
    region             = var.aws_region
    vpcId              = var.vpc_id
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = var.alb_irsa_role_arn
      }
    }
  })]
  depends_on = [helm_release.metrics_server]
}
# external-dns
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "1.15.2"
  values = [yamlencode({
    provider = "aws"
    policy   = "upsert-only"
    txtOwnerId = var.cluster_name
    domainFilters = var.domain_filters
    serviceAccount = {
      create = true
      name   = "external-dns"
      annotations = {
        "eks.amazonaws.com/role-arn" = var.externaldns_irsa_role_arn
      }
    }
    sources = ["service","ingress"]
  })]
}
# cluster-autoscaler
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.43.0"
  values = [yamlencode({
    autoDiscovery = { clusterName = var.cluster_name }
    awsRegion     = var.aws_region
    rbac          = { serviceAccount = { create = true, name = "cluster-autoscaler", annotations = { "eks.amazonaws.com/role-arn" = var.ca_irsa_role_arn } } }
    extraArgs     = { skip-nodes-with-local-storage = "false", balance-similar-node-groups = "true" }
  })]
}
