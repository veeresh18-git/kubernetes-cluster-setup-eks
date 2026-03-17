locals {
  sa_namespace = var.sa_namespace
  sa_name      = var.sa_name
}
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = replace(var.oidc_subject_condition, "{namespace}", local.sa_namespace)
      values   = [format("system:serviceaccount:%s:%s", local.sa_namespace, local.sa_name)]
    }
  }
}
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}
resource "aws_iam_policy" "this" {
  name   = "${var.role_name}-policy"
  policy = var.inline_policy_json
}
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
output "role_arn" { value = aws_iam_role.this.arn }