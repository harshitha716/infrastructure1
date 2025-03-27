

locals {
  name_prefix = "${var.proj_prefix}-${var.name_tag}"
  domain_list = { for i, x in var.static_domain : "domain-${i}" => x.domain }
}


# Static IP
resource "google_compute_global_address" "main" {
  name = "${local.name_prefix}-lb-ip"
}


# Url Map to static website
resource "google_compute_url_map" "https" {
  name = "${local.name_prefix}-https-map"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
  # default_service = "projects/${var.project_id}/global/backendBuckets/${var.proj_prefix}-${var.default_backend_service}"
  dynamic "host_rule" {
    for_each = var.static_domain
    content {
      hosts        = [host_rule.value.domain]
      path_matcher = host_rule.value.name
    }
  }

  dynamic "path_matcher" {
    for_each = var.static_domain
    content {
      name = path_matcher.value.name
      default_url_redirect {
        https_redirect = true
        strip_query    = false
      }
      dynamic "path_rule" {
        for_each = path_matcher.value.routes
        content {
          paths   = ["${path_rule.value.host_path}"]
          service = path_rule.value.redirection ? "" : "projects/${var.project_id}/global/backendBuckets/${var.proj_prefix}-${path_rule.value.backend}"
          dynamic "url_redirect" {
            for_each = path_rule.value.redirection ? [path_rule.value.redirection_path] : []
            content {
              path_redirect          = url_redirect.value
              redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
              strip_query            = false
              https_redirect         = true
            }
          }
        }
      }
      # dynamic "route_rules" {
      #   for_each = path_matcher.value.routes
      #   content {
      #     priority = route_rules.key + 1
      #     service = route_rules.value.redirection ? "" : "projects/${var.project_id}/global/backendBuckets/${var.proj_prefix}-${route_rules.value.backend}"
      #     # service = "projects/${var.project_id}/global/backendBuckets/${var.proj_prefix}-${route_rules.value.backend}"
      #     match_rules {
      #       regex_match = route_rules.value.host_path
      #     }
      #     dynamic "url_redirect" {
      #       for_each = route_rules.value.redirection ? [route_rules.value.redirection_path] : []
      #       content {
      #         path_redirect = url_redirect.value
      #         redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
      #       }
      #     }
      #   }
      # }
    }
  }
}


# create a random hex to enable recreation of the certificate
resource "random_id" "certificate" {
  for_each    = local.domain_list
  keepers     = { "${each.key}" = "${each.value}" }
  byte_length = 4
}

# SSL Certifcate
resource "google_compute_managed_ssl_certificate" "https" {
  for_each = local.domain_list
  name     = "${local.name_prefix}-cert-${random_id.certificate[each.key].hex}"
  managed {
    domains = [each.value]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Route HTTPS traffic to Url Map
resource "google_compute_target_https_proxy" "https" {
  name             = "${local.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.https.self_link
  ssl_certificates = [for v in google_compute_managed_ssl_certificate.https : v.id]

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
