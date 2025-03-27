variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
  default     = "2.8.1"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Kafka broker instance type"
  type        = string
  default     = "kafka.m5.large"
}

variable "ebs_volume_size" {
  description = "Size in GiB of the EBS volume for the data drive on each broker node"
  type        = number
  default     = 1000
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the Kafka brokers"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks to allow access to the Kafka cluster"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encrypting data at rest"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain Kafka broker logs"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the MSK cluster"
  type        = map(string)
  default     = {}
}

