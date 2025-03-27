environment = "PRD-UAE"
service = {
  Service = "AI"
}


region = "me-central-1"

vpcs = [
  {
    name = "zamp-prd-uae-vpc"
    cidr = "172.24.0.0/16"             #VPC CIDR
    tags = {
      Terraformed = "True"
      costCenter  = "prd-uae" #All services costcenter tags will be removed later
    }
  }
]

public_subnets = [
  {
    name              = "zamp-prd-uae-me-central-1a-public-subnet-1"
    cidr              = "172.24.0.0/22"
    availability_zone = "me-central-1a"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/elb"                     = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Public"
    }
  },
  {
    name              = "zamp-prd-uae-me-central-1b-public-subnet-2"
    cidr              = "172.24.4.0/22"
    availability_zone = "me-central-1b"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/elb"                     = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Public"
    }
  }
]

private_subnets = [
  {
    name              = "zamp-prd-uae-me-central-1a-private-subnet-1"
    cidr              = "172.24.8.0/21"
    availability_zone = "me-central-1a"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-prd-uae-me-central-1a-private-subnet-2"
    cidr              = "172.24.16.0/21"
    availability_zone = "me-central-1a"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-prd-uae-me-central-1b-private-subnet-1"
    cidr              = "172.24.24.0/21"
    availability_zone = "me-central-1b"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-prd-uae-me-central-1b-private-subnet-2"
    cidr              = "172.24.32.0/21"
    availability_zone = "me-central-1b"
    tags = {
      "kubernetes.io/cluster/zamp-prd-uae-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  }
]

private_subnet_route_tables = [
  {
    name = "zamp-prd-uae-me-central-1a-private-rt-1"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "prd-uae"
    }
  }
]

public_subnet_route_tables = [
  {
    name = "zamp-prd-uae-me-central-1a-public-rt-1"
    tags = {
      Terraformed = "True"
      SubnetType  = "Public"
      costCenter  = "prd-uae"
    }
  }
]

nat_gateways = [
  {
    name = "zamp-prd-uae-me-central-1a-nat-gw"
    tags = {
      Terraformed = "True"
      costCenter  = "prd-uae"
    }
  }
]

kubernetes_version = "1.31"

cluster_name = "zamp-prd-uae-cluster"

worker_nodes_group_list = [
  {
    name                 = "zamp-prd-uae-workers-ng"
    instance_types       = ["m5.4xlarge"]
    eks_ami_id           = "ami-047bccbe274ff9bcd"
    maximum_capacity     = 10
    minimum_capacity     = 2
    on_demand_percentage = 0
    capacity_type        = "ON_DEMAND"
    tags = {
      Name                                             = "zamp-prd-uae-workers"
      Environment                                      = "prd"
      "kubernetes.io/cluster/zamp-prd-uae-cluster"     = "shared"
      "k8s.io/cluster-autoscaler/zamp-prd-uae-cluster" = "shared"
      PurchaseModel                                    = "ON_DEMAND"
      costCenter                                       = "prd-uae"
    }
  }
]

ecr_repositories = [
  {
    name              = "zamp-prd-uae-pantheon-ecr"
    tags              = { Environment = "prd", costcenter = "prd-uae", Terraformed = "True" }
    enable_scanning   = true
    tag_mutability    = "MUTABLE"
    enable_encryption = true
    enable_lifecycle  = true
  }
]

lifecycle_policy = {
  rulePriority = 1
  description  = "Keep only the last 10 images"
  tagStatus    = "any"
  countType    = "imageCountMoreThan"
  countNumber  = 10
  actionType   = "expire"
}

vpc_flow_logs = {
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  log_group_name       = "vpc-flow-logs"
  log_retention_days   = 30
  environment          = "PRD-UAE"
}


kms_key_alias = "alias/ecr-kms-key"

s3 = {
  bucket_name   = "zamp-prd-uae-s3-bucket-pantheon"
  acl           = "private"
  force_destroy = false
  versioning    = true
  tags = {
    Environment = "PRD-UAE"
  }
}


rds = {
  zamp-prd-uae-db-instance = {
    name                                  = "zamp"  #RDS
    env                                   = "prd-uae"
    db_identifier                         = "zamp-prd-uae-db"
    db_name                               = "zampprduaedb"
    engine                                = "postgres"
    engine_version                        = "15.10"
    allocated_storage                     = 20
    instance_class                        = "db.m6gd.large" # 2 vCPUs, 8 GB RAM
    db_username                           = "zampuae"
    db_password                           = "n2199SfjP"
    parameter_group_name                  = "zamp-prd-uae-parmater-group"
    parameter_group_family                = "postgres15"
    backup_retention_period               = 7
    allocated_storage                     = 20
    port                                  = 5432
    storage_type                          = "gp3"
    auto_minor_version_upgrade            = true
    multi_az                              = false
    publicly_accessible                   = false
    skip_final_snapshot                   = true
    performance_insights_enabled          = true
    performance_insights_retention_period = 7
    copy_tags_to_snapshot                 = true
    storage_encrypted                     = true

    deletion_protection = false
  }
}


secrets = [
  {
    name = "zamp-prd-sg-pantheon-secrets-env"
    description = "Environment variables for pantheon"
    tags              = { Environment = "PRD-UAE", costcenter = "prd-uae", Terraformed = "True" }
  },
  {
    name = "zamp-prd-sg-temporal-cert"
    description = "Certs for pantheon"
    tags              = { Environment = "PRD-UAE", costcenter = "prd-uae", Terraformed = "True" }
  },
  {
    name = "zamp-prd-sg-temporal-cert-key"
    description = "Cert key for pantheon"
    tags              = { Environment = "PRD-UAE", costcenter = "prd-uae", Terraformed = "True" }
  }
]
