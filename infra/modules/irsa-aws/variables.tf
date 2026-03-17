variable "role_name"            { type = string }
variable "oidc_provider_arn"    { type = string }
variable "sa_namespace"         { type = string }
variable "sa_name"              { type = string }
variable "inline_policy_json"   { type = string }
variable "oidc_subject_condition" {
  type        = string
  description = "e.g. 'oidc.eks.{region}.amazonaws.com/id/{id}:sub'"
  default     = "oidc.eks.{region}.amazonaws.com/id/{id}:sub"
}
variable "tags" { type = map(string) }