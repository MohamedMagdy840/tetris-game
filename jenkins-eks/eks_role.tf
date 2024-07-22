#Control plane role
data "aws_iam_policy_document" "assume_role_control" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-cluster-role" { #example
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_control.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" { #example-AmazonEKSClusterPolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

# # Optionally, enable Security Groups for Pods
# # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
# resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" { #example-AmazonEKSVPCResourceController
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks-cluster-role.name
# }

#worker nodes role
# Define IAM policy document for assuming the role
data "aws_iam_policy_document" "assume_role_node_group" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create IAM role for EKS node group
resource "aws_iam_role" "eks_node_group_role" {
  name               = "eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_node_group.json
}

# Attach AmazonEKSWorkerNodePolicy to the node group role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach AmazonEKS_CNI_Policy to the node group role
resource "aws_iam_role_policy_attachment" "AmazonEKSCNIPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

# Attach AmazonEC2ContainerRegistryReadOnly policy to the node group role (ECR read-only access)
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

#policy to can describe autoscaling
resource "aws_iam_role_policy_attachment" "eks-cluster-autoscaler" {
  policy_arn = "arn:aws:iam::590183792206:policy/eks-cluster-autoscaler"
  role       = aws_iam_role.eks_node_group_role.name
}

