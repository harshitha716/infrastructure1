environment = "PRD"

region = "us-east-1"

vpcs = [
  {
    name = "zamp-prd-us-vpc"
    cidr = "172.16.0.0/16"
    tags = {
      Terraformed = "True"
      costCenter  = "base"
    }
  }
]

public_subnets = [
  {
    name              = "zamp1-us-east-1a"
    cidr              = "172.16.0.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/elb"      = "1"
      Terraformed                   = "True"
      SubnetType                    = "Public"
    }
  },
  {
    name              = "zamp1-us-east-1b"
    cidr              = "172.16.16.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/elb"      = "1"
      Terraformed                   = "True"
      SubnetType                    = "Public"
    }
  },
  {
    name              = "zamp1-us-east-1c"
    cidr              = "172.16.32.0/20"  # Adjusted to be in sequence
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/elb"      = "1"
      Terraformed                   = "True"
      SubnetType                    = "Public"
    }
  }
]

private_subnets = [ 
  {
    name              = "zamp1-us-east-1a-1"
    cidr              = "172.16.48.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  },
  {
    name              = "zamp1-us-east-1a-2"
    cidr              = "172.16.64.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  },
  {
    name              = "zamp1-us-east-1b-1"
    cidr              = "172.16.80.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  },
  {
    name              = "zamp1-us-east-1b-2"
    cidr              = "172.16.96.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  },
  {
    name              = "zamp1-us-east-1c-1"
    cidr              = "172.16.112.0/20"
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  },
  {
    name              = "zamp1-us-east-1c-2"
    cidr              = "172.16.128.0/20"
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp1" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                       = "True"
      SubnetType                        = "Private"
    }
  }
]

private_subnet_route_tables = [
  {
    name = "zamp1-us-east-1a"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "base"
    }
  },
  {
    name = "zamp1-us-east-1b"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "base"
    }
  },
  {
    name = "zamp1-us-east-1c"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "base"
    }
  }
]

public_subnet_route_tables = [
  {
    name = "zamp1"
    tags = {
      Terraformed = "True"
      SubnetType  = "Public"
      costCenter  = "base"
    }
  }
]

nat_gateways = [
  {
    name = "zamp1-us-east-1a"
    tags = {
      Terraformed = "True"
      costCenter  = "base"
    }
  },
  {
    name = "zamp1-us-east-1b"
    tags = {
      Terraformed = "True"
      costCenter  = "base"
    }
  },
  {
    name = "zamp1-us-east-1c"
    tags = {
      Terraformed = "True"
      costCenter  = "base"
    }
  }
]


kubernetes_version = "1.31"

cluster_name = "zamp1"

bastion_ssh_key_name = "zamp-bastion-key"
allowed_cidr = "49.207.233.146/32"  # Replace with your IP or allowed CIDR range


worker_nodes_group_list = [
  {
    name                 = "zamp1-workers"
    instance_types       = ["m6g.2xlarge"]
    maximum_capacity     = 10
    minimum_capacity     = 0
    on_demand_percentage = 0
    capacity_type        = "ON_DEMAND"
    tags = {
      Name                               = "zamp1-workers"
      Environment                        = "PROD" 
      "kubernetes.io/cluster/zamp1"      = "shared"
      "k8s.io/cluster-autoscaler/zamp1"  = "shared"
      PurchaseModel                      = "ON_DEMAND"
      costCenter                         = "common"
    }
  }
]

worker_nodes_group_list_public = [
  {
    name                 = "zamp1-workers-public"
    instance_types       = ["m6g.2xlarge"]
    maximum_capacity     = 10
    minimum_capacity     = 1
    on_demand_percentage = 0
    capacity_type        = "ON_DEMAND"
    tags = {
      Name                               = "zamp1-workers-public"
      Environment                        = "PROD" 
      "kubernetes.io/cluster/zamp1"      = "shared"
      "k8s.io/cluster-autoscaler/zamp1"  = "shared"
      PurchaseModel                      = "ON_DEMAND"
      costCenter                         = "common"
    }
  }
]

  controller_node_group = {
    instance_types = ["m6g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 5
    min_size       = 1
    desired_size   = 1
    disk_size      = 50

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "controller"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "controller"
  }
  }

  zookeeper_node_group = {
    instance_types = ["m6g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 5
    min_size       = 1
    desired_size   = 1
    disk_size      = 50

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "zookeeper"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "zookeeper"
  }
  }

  broker_node_group = {
    instance_types = ["m6g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 5
    min_size       = 1
    desired_size   = 1
    disk_size      = 50

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "broker"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "broker"
  }
  }

  server_node_group = {
    instance_types = ["i4g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 15
    min_size       = 9
    desired_size   = 9
    disk_size      = 50

    ebs_optimized = true
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 100
          volume_type = "gp3"
        }
      }
    }

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "server"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "server"
  }
  }

  minion_node_group = {
    instance_types = ["m6g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 3
    min_size       = 1
    desired_size   = 1
    disk_size      = 50

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "minion"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "minion"
  }
  }

  core_node_group = {
    instance_types = ["m6g.4xlarge"]
    capacity_type  = "ON_DEMAND"
    max_size       = 3
    min_size       = 1
    desired_size   = 1
    disk_size      = 50

    labels = {
      WorkerType    = "ON_DEMAND"
      NodeGroupType = "minion"
    }
    taints = [
      {
        key    = "dedicated"
        value  = "pinot"
        effect = "NO_SCHEDULE"
      }
    ]
    tags = {  
    Environment = "Production"
    Project     = "Pinot"
    NodeGroup   = "core"
  }
  }



databricks_vpc_peering_connection = {
  name     = "zamp-to-databricks-quickstart"
  vpc_cidr = "10.215.0.0/16" 

}