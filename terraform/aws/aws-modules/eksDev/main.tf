resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    # public_access_cidrs     = var.openvpn_cidrs
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]

  tags = var.tags
}

resource "aws_launch_template" "eks_node_group_small" {
  name = "${var.cluster_name}-node-group-template_small"
  image_id = var.eks_ami_id
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }
  instance_type = var.worker_nodes_group_list[0].instance_types[0]
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      var.worker_nodes_group_list[0].tags,
      {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    )
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -o xtrace
              /etc/eks/bootstrap.sh \${var.cluster_name}
              EOF
  )
  # lifecycle {
  #   ignore_changes = [
  #     image_id,
  #     latest_version
  #   ]
# } 
}
variable "eks_ami_id" {
  description = "The ID of the EKS optimized AMI for ARM64"
  type        = string
  default     = "ami-03cec8bb42cbfd6ff"  #  aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.31/amazon-linux-2-arm64/recommended/image_id --region us-east-1 --query "Parameter.Value" --output text
}

resource "aws_eks_node_group" "eks_node_group" {
  count           = length(var.worker_nodes_group_list)
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.worker_nodes_group_list[count.index].name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.worker_nodes_group_list[count.index].minimum_capacity
    max_size     = var.worker_nodes_group_list[count.index].maximum_capacity
    min_size     = var.worker_nodes_group_list[count.index].minimum_capacity
  }

   launch_template {
    id      = aws_launch_template.eks_node_group_small.id
    version = aws_launch_template.eks_node_group_small.latest_version
  }

#   instance_types = var.worker_nodes_group_list[count.index].instance_types
  capacity_type  = var.worker_nodes_group_list[count.index].capacity_type

  tags = merge(
    var.tags,
    var.worker_nodes_group_list[count.index].tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}


resource "aws_eks_node_group" "eks_node_group_public" {
  count           = length(var.worker_nodes_group_list_public)
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.worker_nodes_group_list_public[count.index].name
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.public_subnet_ids

  scaling_config {
    desired_size = var.worker_nodes_group_list_public[count.index].minimum_capacity
    max_size     = var.worker_nodes_group_list_public[count.index].maximum_capacity
    min_size     = var.worker_nodes_group_list_public[count.index].minimum_capacity
  }

   launch_template {
    id      = aws_launch_template.eks_node_group_small.id
    version = aws_launch_template.eks_node_group_small.latest_version
  }

#   instance_types = var.worker_nodes_group_list[count.index].instance_types
  capacity_type  = var.worker_nodes_group_list_public[count.index].capacity_type

  tags = merge(
    var.tags,
    var.worker_nodes_group_list_public[count.index].tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
} 

resource "aws_iam_role" "eks_cluster_role" {
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

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-node-group-role"

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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

###

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_oidc_tls_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


# Security Groups
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 443
  type                     = "ingress"
  # cidr_blocks       = var.openvpn_cidrs

}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name                                      = "${var.cluster_name}-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}


resource "aws_security_group_rule" "eks_nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
#   addon_version = "v1.19.0-eksbuild.1"  
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "coredns"
#   addon_version = "v1.11.3-eksbuild.1"  
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"
#   addon_version = "v1.31.2-eksbuild.1" 
}

resource "aws_eks_addon" "cloudwatch-observability" {
  addon_name   = "amazon-cloudwatch-observability"
  cluster_name = aws_eks_cluster.eks_cluster.name
}

data "aws_iam_policy_document" "ebs_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role_policy.json
  name               = "${var.cluster_name}-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
#   addon_version = "v1.37.0-eksbuild.1"  
}

resource "aws_eks_node_group" "eks_node_groups" {
  for_each = {
    core        = var.core_node_group
    controller  = var.controller_node_group
    zookeeper   = var.zookeeper_node_group
    broker      = var.broker_node_group
    server      = var.server_node_group
    minion      = var.minion_node_group
  }

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnet_ids  # Only use private subnets for node groups

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_node_group_template[each.key].id
    version = aws_launch_template.eks_node_group_template[each.key].latest_version
  }

  capacity_type = each.value.capacity_type

  labels = each.value.labels

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.tags,
    each.value.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}


resource "aws_launch_template" "eks_node_group_template" {
  for_each = {
    core        = var.core_node_group
    controller  = var.controller_node_group
    zookeeper   = var.zookeeper_node_group
    broker      = var.broker_node_group
    server      = var.server_node_group
    minion      = var.minion_node_group
  }

  name = "${var.cluster_name}-${each.key}-template"
  image_id = var.eks_ami_id
  instance_type = each.value.instance_types[0]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      each.value.tags,
      {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    )
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -o xtrace
              /etc/eks/bootstrap.sh \${var.cluster_name}
              EOF
  )
    lifecycle {
    ignore_changes = [
      image_id,
      latest_version
    ]
} 
}

#IAM access for EKS
