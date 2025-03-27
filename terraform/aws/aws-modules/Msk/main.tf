resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [aws_security_group.kafka_sg.id]
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = 1
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  # logging_info {
  #   broker_logs {
  #     cloudwatch_logs {
  #       enabled   = true
  #       log_group = aws_cloudwatch_log_group.kafka_logs.name
  #     }
  #   }
  # }

  tags = var.tags
}

resource "aws_msk_configuration" "kafka_config" {
  name              = "${var.cluster_name}-config"
  kafka_versions    = ["3.6.0"]
  server_properties = <<PROPERTIES
log.retention.ms=259200000
auto.create.topics.enable=false
PROPERTIES
}

resource "aws_security_group" "kafka_sg" {
  name_prefix = "${var.cluster_name}-kafka-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

    ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = ["10.215.0.0/16"]
  }
      ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.215.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-kafka-sg"
  })
}

resource "aws_cloudwatch_log_group" "kafka_logs" {
  name              = "/aws/msk/${var.cluster_name}"
  retention_in_days = 3

  tags = var.tags
}
