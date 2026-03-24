variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "cluster_name" {
  type    = string
  default = "ksd-eks"
}
variable "cluster_version" {
  type    = string
  default = "1.29"
}
variable "tags" {
  type    = map(string)
  default = { "env" = "pdev", "stack" = "eks" }
}