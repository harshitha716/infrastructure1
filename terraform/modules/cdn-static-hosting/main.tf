locals {
  name_prefix  = "${var.proj_prefix}-${var.name_tag}"
  cert_domains = [var.static_hosting_domain]
}


# Creating bucket for website
resource "google_storage_bucket" "main" {
  name                        = "${local.name_prefix}-static"
  location                    = "ASIA"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
  logging {
          log_bucket        = "zamp-prd-sg-gcs-logging" 
          log_object_prefix = "AccessLog" 
        }
}

#

# Making bucket public
resource "google_storage_bucket_iam_binding" "main" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}

# Static IP
resource "google_compute_global_address" "main" {
  name = "${local.name_prefix}-lb-ip"
}

resource "google_compute_security_policy" "policy" {
  count = var.only_vpn_access ? 1 : 0
  name        = "${local.name_prefix}-vpn-only-access"
  description = "VPN only access"
  # type = "CLOUD_ARMOR_EDGE"

  # rule {
  #   action   = "allow"
  #   priority = "1000"
  #   match {
  #     versioned_expr = "SRC_IPS_V1"
  #     config {
  #       src_ip_ranges = [var.vpn_connector_ip]
  #     }
  #   }
  #   description = "Access to openvpn connector IP"
  # }
  # rule {
  #   action   = "deny(403)"
  #   priority = "2147483647"
  #   match {
  #     versioned_expr = "SRC_IPS_V1"
  #     config {
  #       src_ip_ranges = ["0.0.0.0/0"]
  #     }
  #   }
  #   description = "Deny access to all IPs other than VPN IP"
  # }
}

# Backend - Bucket target
resource "google_compute_backend_bucket" "main" {
  name        = "${local.name_prefix}-backend-static"
  description = "Backend bucket for serving static content through CDN"
  bucket_name = google_storage_bucket.main.name
  enable_cdn  = true
  #edge_security_policy = var.only_vpn_access ? google_compute_security_policy.policy[0].id : null
}


# Url Map to static website
resource "google_compute_url_map" "https" {
  name            = "${local.name_prefix}-https-map"
  default_service = google_compute_backend_bucket.main.self_link
  host_rule {
    hosts        = ["${var.static_hosting_domain}"]
    path_matcher = "website"
  }
  path_matcher {
    name            = "website"
    default_service = google_compute_backend_bucket.main.id
  }
}


# create a random hex to enable recreation of the certificate
resource "random_id" "certificate" {
  keepers = {
    domain = var.static_hosting_domain
  }
  byte_length = 4
}

# SSL Certifcate
resource "google_compute_managed_ssl_certificate" "https" {
  name = "${local.name_prefix}-cert-${random_id.certificate.hex}"
  managed {
    domains = local.cert_domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route HTTPS traffic to Url Map
resource "google_compute_target_https_proxy" "https" {
  name             = "${local.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.https.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.https.self_link]

  # depends_on = [google_compute_managed_ssl_certificate.https]
}

# Route traffic to Correct Loadbalancer
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${local.name_prefix}-https-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.main.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https.self_link
}

### HTTPS Redirect

# Url Map - Redirect to https
resource "google_compute_url_map" "http" {
  count = var.enable_https_redirect ? 1 : 0
  name  = "${local.name_prefix}-http-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# Route HTTP traffic to Url Map
resource "google_compute_target_http_proxy" "http" {
  count   = var.enable_https_redirect ? 1 : 0
  name    = "${local.name_prefix}-http-proxy"
  url_map = google_compute_url_map.http[0].self_link
}

# Route traffic to Correct Loadbalancer
resource "google_compute_global_forwarding_rule" "http" {
  count                 = var.enable_https_redirect ? 1 : 0
  name                  = "${local.name_prefix}-http-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.main.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http[0].self_link
}
