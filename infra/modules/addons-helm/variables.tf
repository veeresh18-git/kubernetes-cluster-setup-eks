variable "cluster_name"            { type = string }
variable "aws_region"              { type = string }
variable "vpc_id"                  { type = string }
variable "alb_irsa_role_arn"       { type = string }
variable "externaldns_irsa_role_arn" { type = string }
variable "ca_irsa_role_arn"        { type = string }
variable "domain_filters"          { type = list(string) }
