resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.28"

  vpc_config {
    subnet_ids         = [var.private_subnet, var.public_subnet]
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Launch Template Configuration
# resource "aws_launch_template" "eks_nodes" {
#   name_prefix   = "${var.cluster_name}-nodes-"
#   instance_type = "t2.large"
#   key_name      = "classdemo"

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       volume_size           = 30
#       volume_type           = "gp3"
#       delete_on_termination = true
#       encrypted             = true
#     }
#   }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required" # IMDSv2 enforced
#     http_put_response_hop_limit = 2
#   }

#   network_interfaces {
#     # associate_public_ip_address = true
#     security_groups             = [aws_security_group.eks_nodes.id]
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name = "${var.cluster_name}-worker-node"
#     }
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Node Group using Launch Template
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [var.private_subnet, var.public_subnet]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # launch_template {
  #   id      = aws_launch_template.eks_nodes.id
  #   version = aws_launch_template.eks_nodes.latest_version
  # }

  instance_types = [ "t2.large" ]

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "nodes" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes allowing all traffic"
  vpc_id      = var.vpc_id

  # Allow ALL inbound traffic from any IP
  ingress {
    description = "Allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Cluster API to node"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }


  # Allow ALL outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.nodes.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }

  depends_on = [aws_eks_cluster.cluster]
}

# # CoreDNS Add-on
# resource "aws_eks_addon" "coredns" {
#   cluster_name      = aws_eks_cluster.cluster.name
#   addon_name        = "coredns"
#   addon_version     = "v1.10.1-eksbuild.18"
#   depends_on        = [aws_eks_node_group.nodes]
# }

# # kube-proxy Add-on
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name      = aws_eks_cluster.cluster.name
#   addon_name        = "kube-proxy"
#   addon_version     = "v1.28.15-eksbuild.9"
#   depends_on        = [aws_eks_node_group.nodes]
# }

# # VPC CNI Add-on
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name      = aws_eks_cluster.cluster.name
#   addon_name        = "vpc-cni"
#   addon_version     = "v1.19.2-eksbuild.5"
#   depends_on        = [aws_eks_node_group.nodes]
# }

# # EBS CSI Driver Add-on
# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name             = aws_eks_cluster.cluster.name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.28.0-eksbuild.1"
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
#   depends_on               = [aws_eks_node_group.nodes]
# }

# # IAM Role for EBS CSI Driver
# resource "aws_iam_role" "ebs_csi_driver" {
#   name = "${var.cluster_name}-ebs-csi-driver-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com",
#             "${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# data "aws_caller_identity" "current" {}


data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}