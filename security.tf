# Cloud Armor Security Policy (WAF) configuration

resource "google_compute_security_policy" "waf_policy" {
  name = var.waf_policy_name

  # Rule to block common OWASP attacks (specifically SQLi for this demo)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        # This uses a pre-configured Google Cloud Armor expression for SQL Injection
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "Block SQL Injection attempts"
  }

  # Default rule to allow traffic that doesn't match block rules
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow"
  }
}
