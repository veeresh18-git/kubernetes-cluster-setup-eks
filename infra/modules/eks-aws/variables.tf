variable "cluster_name"      { type = string }
variable "cluster_version"   { type = string }
variable "vpc_id"            { type = string }
variable "private_subnets"   { type = list(string) }
variable "kms_key_arn"       { type = string }
variable "tags"              { type = map(string) }