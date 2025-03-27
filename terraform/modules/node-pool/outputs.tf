output "cluster_name" {
    value = google_container_node_pool.managed_pool.cluster
}

output "node_pool_name" {
    value = google_container_node_pool.managed_pool.name
}