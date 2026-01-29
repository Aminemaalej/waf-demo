# Allow Health Checks and Load Balancer traffic to reach the VM
resource "google_compute_firewall" "allow_http_lb" {
  name    = "allow-http-lb"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # GCP Health Check IP ranges and Load Balancer IP ranges
  # https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server"]

  description = "Allow HTTP traffic from GCP health checks and load balancer"
}
