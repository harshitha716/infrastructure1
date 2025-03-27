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
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  capacity_type  = var.worker_nodes_group_list[count.index].capacity_type

  tags = merge(
    var.tags,
    var.worker_nodes_group_list[count.index].tags,
    var.service
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}




resource "aws_launch_template" "eks_node_group" {
  name = "${var.cluster_name}-node-group-template"
  image_id = var.worker_nodes_group_list[0].eks_ami_id
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
  
}
