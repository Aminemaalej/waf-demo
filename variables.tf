variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for the VM instance"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for the web server VM"
  type        = string
  default     = "e2-micro"
}

variable "vm_name" {
  description = "Name of the vulnerable web application VM"
  type        = string
  default     = "vulnerable-web-app"
}

variable "network" {
  description = "The VPC network to use"
  type        = string
  default     = "default"
}

variable "waf_policy_name" {
  description = "Name of the Cloud Armor WAF policy"
  type        = string
  default     = "demo-waf-policy"
}
