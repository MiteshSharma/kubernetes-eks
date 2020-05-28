data "aws_ami" "node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.15-*"]
  }
 
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encode this
# information and write it into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = data.aws_ami.node.id
  instance_type               = var.instance_type
  name_prefix                 = "eks"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(local.eks-node-userdata)
  key_name                    = aws_key_pair.ec2key.key_name
 
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = "2"
  launch_configuration = aws_launch_configuration.eks.id
  max_size             = "3"
  min_size             = "1"
  name                 = "terraform-tf-eks"
  vpc_zone_identifier  = aws_subnet.networking.*.id
 
  tag {
    key                 = "Environment"
    value               = var.environment_tag
    propagate_at_launch = true
  }
 
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }
}