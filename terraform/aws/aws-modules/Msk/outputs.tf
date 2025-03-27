output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.kafka_cluster.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  description = "Zookeeper connection string"
  value       = aws_msk_cluster.kafka_cluster.zookeeper_connect_string
}

output "security_group_id" {
  description = "ID of the security group created for the MSK cluster"
  value       = aws_security_group.kafka_sg.id
}