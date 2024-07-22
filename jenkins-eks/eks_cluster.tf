
#Create control plane
resource "aws_eks_cluster" "eks-cluster-test" { #example
  name     = "eks-cluster-test"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_01.id,
      aws_subnet.public_subnet_02.id,
      aws_subnet.private_subnet_01.id,
      aws_subnet.private_subnet_02.id
    ]
    security_group_ids = [aws_security_group.eks_cluster_sg.id] # Attach the security group
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    #aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]
}

# Install AWS VPC CNI using EKS Addon
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks-cluster-test.name
  addon_name   = "vpc-cni"
}

# Install Kube Proxy using EKS Addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks-cluster-test.name
  addon_name   = "kube-proxy"
}

# Install CoreDNS using EKS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks-cluster-test.name
  addon_name   = "coredns"
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster-test.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster-test.certificate_authority[0].data
}

#create node-group
resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster-test.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]
  

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_security_group" "eks_cluster_sg" {
    name        = "eks-cluster-sg"
    description = "Security group for the EKS cluster"
    vpc_id = aws_vpc.node_vpc.id
    #Ingress rule allowing all traffic
    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    #Egress rule allowing all traffic
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      #prefix_list_ids = []
      #attribute is used when you want to allow traffic from AWS services that use prefix list IDs
    }
  }
