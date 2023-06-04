resource "google_compute_global_forwarding_rule" "this" {
  provider   = google-beta
  name       = "mike-https"
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.global_address.address
  port_range = "443"
}

resource "google_compute_global_address" "global_address" {
  provider   = google-beta
  name       = "mike-address"
  ip_version = "IPV4"
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name          = "mike-https-proxy"
  url_map       = google_compute_url_map.url_map.id
  ssl_policy    = ""
  quic_override = "NONE"
}
resource "google_compute_region_network_endpoint_group" "api_gateway_neg" {
  provider              = google-beta
  name                  = "api-gateway-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_name
  lifecycle {
    create_before_destroy = true
  }
  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_api._api_gateway_api.id
  }
}
resource "google_compute_backend_service" "backend_service_api_gateway" {
  provider                        = google-beta
  project                         = var.project_name
  name                            = "mike-backend-api-gateway"
  description                     = "api_gateway"
  connection_draining_timeout_sec = 10
  enable_cdn                      = false
  backend {
    group = google_compute_region_network_endpoint_group.api_gateway_neg.id
  }
  # To achieve a null backend security_policy, set each.value.security_policy to "" (empty string), otherwise, it fallsback to var.security_policy.
  security_policy = ""
}
resource "google_compute_url_map" "url_map" {
  project         = var.project_name
  name            = "mike-url-map"
  default_service = google_compute_backend_service.backend_service_api_gateway.id

  host_rule {
    hosts        = ["not_defined_yet"]
    path_matcher = "mike-apps"
  }

  path_matcher {
    name            = "mike-apps"
    default_service = google_compute_backend_service.backend_service_api_gateway.id
    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.backend_service_api_gateway.id
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}


