output "vpc_id" {
  value = google_compute_network.vpc_network.id
}
output network {
  value  = google_compute_network.vpc_network.self_link
}