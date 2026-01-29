# Instance Group (required for the Load Balancer backend)
resource "google_compute_instance_group" "web_servers" {
  name        = "web-servers-ig"
  description = "Instance group for web servers"
  instances   = [google_compute_instance.web_server.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# Health Check for backend instances
resource "google_compute_health_check" "http_health_check" {
  name = "http-basic-check"

  http_health_check {
    port = 80
  }
}

# Backend Service with Cloud Armor WAF policy attached
resource "google_compute_backend_service" "default" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.http_health_check.self_link]
  port_name     = "http"
  protocol      = "HTTP"

  backend {
    group = google_compute_instance_group.web_servers.self_link
  }

  # Attach the Cloud Armor WAF policy
  security_policy = google_compute_security_policy.waf_policy.self_link
}

# URL Map - routes incoming requests to the backend service
resource "google_compute_url_map" "default" {
  name            = "url-map"
  default_service = google_compute_backend_service.default.self_link
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy"
  url_map = google_compute_url_map.default.self_link
}

# Global Forwarding Rule - the external entry point
resource "google_compute_global_forwarding_rule" "default" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
}
