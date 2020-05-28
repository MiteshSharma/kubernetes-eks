resource "aws_iam_role" "cluster_autoscaler" {
  name = "kube-cluster-autoscaler-role"

  assume_role_policy = templatefile("policies/oidc_assume_role.json", { OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn, OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "kube-system", SA_NAME = "cluster-autoscaler" })

  tags = {
    "Environment" = var.environment_tag
  }

  depends_on = [aws_iam_openid_connect_provider.cluster]
}

resource "aws_iam_role_policy" "cluster_autoscaler_policy" {
  name = "ClusterAutoScalerPolicy"
  role = aws_iam_role.cluster_autoscaler.id

  policy = templatefile("policies/cluster_autoscaler_policy.json", {})

  depends_on = [
    aws_iam_role.cluster_autoscaler
  ]
}