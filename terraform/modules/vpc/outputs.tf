output network {
  value  = google_compute_network.vpc.self_link
}
output public_subnet {
  value  = google_compute_subnetwork.public.self_link
}
output private_subnet {
  value  = google_compute_subnetwork.private.self_link
}
output public_subnet_primary_cidr {
  value  = google_compute_subnetwork.public.ip_cidr_range
}
output private_subnet_primary_cidr {
  value  = google_compute_subnetwork.private.ip_cidr_range
}
output public_subnet_cidrs {
  value  = concat(
    [google_compute_subnetwork.public.ip_cidr_range],
    google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
  )
}
output private_subnet_cidrs {
  value  = concat(
    [google_compute_subnetwork.private.ip_cidr_range],
    google_compute_subnetwork.private.secondary_ip_range.*.ip_cidr_range,
    )
}
output all_subnet_cidrs {
  value = concat(
    [google_compute_subnetwork.public.ip_cidr_range],
    [google_compute_subnetwork.private.ip_cidr_range],
    google_compute_subnetwork.public.secondary_ip_range.*.ip_cidr_range,
    google_compute_subnetwork.private.secondary_ip_range.*.ip_cidr_range,
  )
}