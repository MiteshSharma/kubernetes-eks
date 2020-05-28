# EKS Cluster Resources

resource "aws_eks_cluster" "eks" {
  name = var.cluster_name

  version = "1.15"

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = aws_subnet.networking.*.id
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.eks-logs-group
  ]
}

resource "aws_cloudwatch_log_group" "eks-logs-group" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 3
}