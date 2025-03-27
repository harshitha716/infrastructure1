environment = "dev-us"

service = {
  Service = "AI"
}

region = "us-east-1"
aws_account_id = "842675998483"

github_repository  = ["Zampfi/pantheon", "Zampfi/infrastructure"]  
role_name    = "GitHubActionsRole"
terraform_oidc_policy = "AdministratorAccess"


vpcs = [
  {
    name = "zamp-dev-us-vpc"
    cidr = "172.24.0.0/16"             #VPC CIDR
    tags = {
      Terraformed = "True"
      costCenter  = "dev-us" #All services costcenter tags will be removed later
    }
  }
]

public_subnets = [
  {
    name              = "zamp-dev-us-us-east-1a-public-subnet-1"
    cidr              = "172.24.0.0/22"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/elb"                     = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Public"
    }
  },
  {
    name              = "zamp-dev-us-us-east-1b-public-subnet-2"
    cidr              = "172.24.4.0/22"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/elb"                     = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Public"
    }
  }
]

private_subnets = [
  {
    name              = "zamp-dev-us-us-east-1a-private-subnet-1"
    cidr              = "172.24.8.0/21"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-dev-us-us-east-1a-private-subnet-2"
    cidr              = "172.24.16.0/21"
    availability_zone = "us-east-1a"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-dev-us-us-east-1b-private-subnet-3"
    cidr              = "172.24.24.0/21"
    availability_zone = "us-eats-1b"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  },
  {
    name              = "zamp-dev-us-us-east-1b-private-subnet-4"
    cidr              = "172.24.32.0/21"
    availability_zone = "us-east-1b"
    tags = {
      "kubernetes.io/cluster/zamp-dev-us-cluster" = "shared"
      "kubernetes.io/role/internal-elb"            = "1"
      Terraformed                                  = "True"
      SubnetType                                   = "Private"
    }
  }
]

private_subnet_route_tables = [
  {
    name = "zamp-dev-us-us-east-1a-private-rt-1"
    tags = {
      Terraformed = "True"
      SubnetType  = "Private"
      costCenter  = "dev-us"
    }
  }
]

public_subnet_route_tables = [
  {
    name = "zamp-dev-us-us-east-1a-public-rt-1"
    tags = {
      Terraformed = "True"
      SubnetType  = "Public"
      costCenter  = "dev-us"
    }
  }
]

nat_gateways = [
  {
    name = "zamp-dev-us-us-east-1a-nat-gw"
    tags = {
      Terraformed = "True"
      costCenter  = "dev-us"
    }
  }
]

kubernetes_version = "1.31"

cluster_name = "zamp-dev-us-cluster"

worker_nodes_group_list = [
  {
    name                 = "zamp-dev-us-workers-ng"
    instance_types       = ["m5.4xlarge"]
    eks_ami_id           = "ami-047bccbe274ff9bcd"     #Update AMI based on region
    maximum_capacity     = 10
    minimum_capacity     = 2
    on_demand_percentage = 0
    capacity_type        = "ON_DEMAND"
    tags = {
      Name                                             = "zamp-dev-us-workers"
      Environment                                      = "dev"
      "kubernetes.io/cluster/zamp-dev-us-cluster"     = "shared"
      "k8s.io/cluster-autoscaler/zamp-dev-us-cluster" = "shared"
      PurchaseModel                                    = "ON_DEMAND"
      costCenter                                       = "dev-us"
    }
  }
]

ecr_repositories = [
  {
    name              = "zamp-dev-us-pantheon-ecr"
    tags              = { Environment = "dev", costcenter = "dev-us", Terraformed = "True" }
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
  environment          = "dev-us"
}


kms_key_alias = "alias/ecr-kms-key"

s3 = {                                                    #Update naming convention
  bucket_name   = "zamp-dev-us-s3-bucket-pantheon"
  acl           = "private"
  force_destroy = false
  versioning    = true
  tags = {
    Environment = "dev-us"
  }
}


rds = {
  zamp-dev-us-db-instance = {
    name                                  = "zamp"  #RDS
    env                                   = "dev-us"
    db_identifier                         = "zamp-dev-us-db"
    db_name                               = "zampdevusdb"
    engine                                = "postgres"
    engine_version                        = "15.10"
    allocated_storage                     = 20
    instance_class                        = "db.m6gd.large" # 2 vCPUs, 8 GB RAM
    db_username                           = "zampus"
    db_password                           = "n2199SfjP"
    parameter_group_name                  = "zamp-dev-us-parmater-group"
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
    name = "zamp-dev-us-sg-pantheon-secrets-env"
    description = "Environment variables for pantheon"
    tags              = { Environment = "dev-us", costcenter = "dev-us", Terraformed = "True" }
  },
  {
    name = "zamp-dev-sg-temporal-cert"
    description = "Certs for pantheon"
    tags              = { Environment = "dev-us", costcenter = "dev-us", Terraformed = "True" }
  },
  {
    name = "zamp-dev-sg-temporal-cert-key"
    description = "Cert key for pantheon"
    tags              = { Environment = "dev-us", costcenter = "dev-us", Terraformed = "True" }
  }
]
