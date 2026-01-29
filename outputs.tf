output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.default.ip_address
  description = "The external IP address of the load balancer. Wait 5-10 mins after apply for full propagation."
}

output "demo_url" {
  value       = "http://${google_compute_global_forwarding_rule.default.ip_address}/"
  description = "The URL to access the demo application"
}

output "sqli_test_url" {
  value       = "http://${google_compute_global_forwarding_rule.default.ip_address}/?query=' OR 1=1 --"
  description = "URL to test SQL injection blocking (should return 403)"
}

output "vm_name" {
  value       = google_compute_instance.web_server.name
  description = "Name of the web server VM instance"
}

output "waf_policy_name" {
  value       = google_compute_security_policy.waf_policy.name
  description = "Name of the Cloud Armor WAF security policy"
}
