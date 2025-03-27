environment = "DEV"

region = "us-east-1"

vpcs = [
  {
    name = "zamp-dev-us-vpc"
    cidr = "172.20.0.0/16"
    tags = {
      Terraformed = "True"
      costCenter  = "dev"
    }
  }
]

public_subnets = [
  {
    name              = "zamp-dev-us-east-1a"
    cidr              = "172.20.0.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/elb"         = "1"
      Terraformed                      = "True"
      SubnetType                       = "Public"
    }
  },
  {
    name              = "zamp-dev-us-east-1b"
    cidr              = "172.20.16.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/elb"         = "1"
      Terraformed                      = "True"
      SubnetType                       = "Public"
    }
  },
  {
    name              = "zamp-dev-us-east-1c"
    cidr              = "172.20.32.0/20"
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/elb"         = "1"
      Terraformed                      = "True"
      SubnetType                       = "Public"
    }
  }
]

private_subnets = [ 
  {
    name              = "zamp-dev-us-east-1a-1"
    cidr              = "172.20.48.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  },
  {
    name              = "zamp-dev-us-east-1a-2"
    cidr              = "172.20.64.0/20"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  },
  {
    name              = "zamp-dev-us-east-1b-1"
    cidr              = "172.20.80.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  },
  {
    name              = "zamp-dev-us-east-1b-2"
    cidr              = "172.20.96.0/20"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  },
  {
    name              = "zamp-dev-us-east-1c-1"
    cidr              = "172.20.112.0/20"
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  },
  {
    name              = "zamp-dev-us-east-1c-2"
    cidr              = "172.20.128.0/20"
    availability_zone = "us-east-1c"
    tags = {
      "kubernetes.io/cluster/zamp-us-dev-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = "1"
      Terraformed                        = "True"
      SubnetType                         = "Private"
    }
  }
]

private_subnet_route_tables = [
  {
    name = "zamp-dev-us-east-1a"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "dev"
    }
  },
  {
    name = "zamp-dev-us-east-1b"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "dev"
    }
  },
  {
    name = "zamp-dev-us-east-1c"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "dev"
    }
  }
]

public_subnet_route_tables = [
  {
    name = "zamp-dev"
    tags = {
      Terraformed = "True"
      SubnetType  = "Public"
      costCenter  = "dev"
    }
  }
]

nat_gateways = [
  {
    name = "zamp-dev-us-east-1a"
    tags = {
      Terraformed = "True"
      costCenter  = "dev"
    }
  },
  {
    name = "zamp-dev-us-east-1b"
    tags = {
      Terraformed = "True"
      costCenter  = "dev"
    }
  },
  {
    name = "zamp-dev-us-east-1c"
    tags = {
      Terraformed = "True"
      costCenter  = "dev"
    }
  }
]

kubernetes_version = "1.31"

cluster_name = "zamp-us-dev-cluster"

# worker_nodes_group_list = [
#   {
#     name                 = "zamp-dev-workers"
#     instance_types       = ["m6g.2xlarge"]
#     maximum_capacity     = 10
#     minimum_capacity     = 1
#     on_demand_percentage = 0
#     capacity_type        = "ON_DEMAND"
#     tags = {
#       Name                               = "zamp-dev-workers"
#       Environment                        = "dev" 
#       "kubernetes.io/cluster/zamp-us-dev-cluster"      = "shared"
#       "k8s.io/cluster-autoscaler/zamp-us-dev-cluster"  = "shared"
#       PurchaseModel                      = "ON_DEMAND"
#       costCenter                         = "dev"
#     }
#   }
# ]

# worker_nodes_group_list_public = [
#   {
#     name                 = "zamp-dev-workers-public"
#     instance_types       = ["m6g.2xlarge"]
#     maximum_capacity     = 10
#     minimum_capacity     = 1
#     on_demand_percentage = 0
#     capacity_type        = "ON_DEMAND"
#     tags = {
#       Name                               = "zamp-dev-workers-public"
#       Environment                        = "dev" 
#       "kubernetes.io/cluster/zamp-us-dev-cluster"      = "shared"
#       "k8s.io/cluster-autoscaler/zamp-us-dev-cluster"  = "shared"
#       PurchaseModel                      = "ON_DEMAND"
#       costCenter                         = "dev"
#     }
#   }
# ]

#   controller_node_group = {
#     instance_types = ["m6g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 5
#     min_size       = 2
#     desired_size   = 2
#     disk_size      = 50

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "controller"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "controller"
#     costCenter  = "dev"
#   }
#   }

#   zookeeper_node_group = {
#     instance_types = ["m6g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 5
#     min_size       = 2
#     desired_size   = 2
#     disk_size      = 50

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "zookeeper"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "zookeeper"
#     costCenter  = "dev"
#   }
#   }

#   broker_node_group = {
#     instance_types = ["m6g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 5
#     min_size       = 2
#     desired_size   = 2
#     disk_size      = 50

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "broker"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "broker"
#     costCenter  = "dev"
#   }
#   }

#   server_node_group = {
#     instance_types = ["i4g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 9
#     min_size       = 3
#     desired_size   = 3
#     disk_size      = 50

#     ebs_optimized = true
#     block_device_mappings = {
#       xvda = {
#         device_name = "/dev/xvda"
#         ebs = {
#           volume_size = 100
#           volume_type = "gp3"
#         }
#       }
#     }

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "server"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "server"
#     costCenter  = "dev"
#   }
#   }

#   minion_node_group = {
#     instance_types = ["m6g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 3
#     min_size       = 2
#     desired_size   = 2
#     disk_size      = 50

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "minion"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "minion"
#     costCenter  = "dev"
#   }
#   }

#   core_node_group = {
#     instance_types = ["m6g.xlarge"]
#     capacity_type  = "ON_DEMAND"
#     max_size       = 3
#     min_size       = 2
#     desired_size   = 2
#     disk_size      = 50

#     labels = {
#       WorkerType    = "ON_DEMAND"
#       NodeGroupType = "minion"
#     }
#     taints = [
#       {
#         key    = "dedicated"
#         value  = "pinot"
#         effect = "NO_SCHEDULE"
#       }
#     ]
#     tags = {  
#     Environment = "Development"
#     Project     = "Pinot"
#     NodeGroup   = "core"
#     costCenter  = "dev"
#   }
#   }

databricks_vpc_peering_connection = {
  name     = "zamp-to-databricks-dev"
  vpc_cidr = "10.0.0.0/16" 

}