output "ip_address" {
  value = google_compute_global_address.main.address
}

# output "domain" {
#   value = var.cdn_domain
# }