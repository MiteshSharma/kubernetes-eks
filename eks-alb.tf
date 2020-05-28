data "external" "thumb" {
  program = ["scripts/oidc_thumbprint.sh", var.region]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumb.result.thumbprint]
  url             = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

resource "aws_iam_role" "alb_ingress_controller" {
  name = "kube-alb-ingress-role"

  assume_role_policy = templatefile("policies/oidc_assume_role.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "alb-ingress-controller" })

  tags = {
    "Environment" = var.environment_tag
  }

  depends_on = [aws_iam_openid_connect_provider.cluster]
}

resource "aws_iam_role_policy" "alb_ingress_controller" {
  name = "ALBIngressControllerPolicy"
  role = aws_iam_role.alb_ingress_controller.id

  policy = templatefile("policies/alb_ingress_controller_policy.json", {})

  depends_on = [
    aws_iam_role.alb_ingress_controller
  ]
}