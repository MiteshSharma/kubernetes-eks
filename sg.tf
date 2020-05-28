resource "aws_security_group" "cluster" {
  name        = "cluster_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.networking.id

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "node" {
  name        = "node_sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.networking.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment" = var.environment_tag
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "eks-node-ingress-machine-ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow local machine to communicate with the Kubernetes nodes directly."
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.node.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-machine-https" {
  cidr_blocks     = ["0.0.0.0/0"]
  description       = "Allow local machine to communicate with the cluster API Server."
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-master" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  to_port                  = 443
  type                     = "ingress"
}