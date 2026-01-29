# GCP Cloud Armor WAF Demo

A Terraform-based demo environment that deploys a vulnerable Python Flask application behind a Google Cloud HTTP Load Balancer, protected by Cloud Armor (GCP's Web Application Firewall).

This demo is designed to showcase how Cloud Armor detects and blocks common web attacks like SQL Injection in real-time.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              Google Cloud                                │
│                                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────────┐   │
│  │   Internet   │───▶│ Cloud Armor  │───▶│   HTTP Load Balancer     │   │
│  │   Traffic    │    │  (WAF)       │    │   - Forwarding Rule      │   │
│  └──────────────┘    │              │    │   - URL Map              │   │
│                      │  ┌────────┐  │    │   - Backend Service      │   │
│                      │  │ SQLi   │  │    └───────────┬──────────────┘   │
│                      │  │ Rules  │  │                │                  │
│                      │  └────────┘  │                ▼                  │
│                      └──────────────┘    ┌──────────────────────────┐   │
│                                          │   Instance Group          │   │
│                                          │   ┌──────────────────┐   │   │
│                                          │   │  Compute Engine  │   │   │
│                                          │   │  (Flask App)     │   │   │
│                                          │   └──────────────────┘   │   │
│                                          └──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

## What Gets Deployed

| Resource | Description |
|----------|-------------|
| **Cloud Armor Policy** | WAF policy with SQL Injection (`sqli-stable`) detection rules |
| **Compute Engine VM** | Debian 11 VM running a vulnerable Flask application |
| **Instance Group** | Unmanaged instance group for load balancer backend |
| **Health Check** | HTTP health check on port 80 |
| **Backend Service** | Backend service with Cloud Armor policy attached |
| **URL Map** | Routes all traffic to the backend service |
| **HTTP Proxy** | Target HTTP proxy for the load balancer |
| **Forwarding Rule** | Global forwarding rule exposing the application on port 80 |
| **Firewall Rule** | Allows traffic from GCP health checks and load balancer |

## Prerequisites

- [Google Cloud Platform Project](https://console.cloud.google.com/) with billing enabled
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [Terraform](https://www.terraform.io/downloads) v1.0.0 or later

## Quick Start

### 1. Clone and Configure

```bash
# Navigate to the project directory
cd waf-demo

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your GCP project ID
# project_id = "your-actual-project-id"
```

### 2. Authenticate with GCP

```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply
```

### 4. Wait for Propagation

> **Important:** Google Cloud Load Balancers take **5-10 minutes** to fully program and recognize the backend VM.

After `terraform apply` completes, you'll see the `load_balancer_ip` output. If you visit the IP immediately, you may get a 404 or 502 error. Wait until the "Welcome to the WAF Demo App" page loads.

## Demo Scenarios

Once the application is accessible, you can demonstrate the WAF in action:

### Scenario A: Normal Traffic (Allowed)

Visit the application with a normal query:

```
http://<LOAD_BALANCER_IP>/?query=hello
```

**Expected Result:** The page loads and displays "You searched for: hello"

### Scenario B: SQL Injection Attack (Blocked)

Attempt a SQL injection attack:

```
http://<LOAD_BALANCER_IP>/?query=' OR 1=1 --
```

**Expected Result:** A `403 Forbidden` error page - Cloud Armor blocked the malicious request!


## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | (required) |
| `region` | GCP region | `us-central1` |
| `zone` | GCP zone | `us-central1-a` |
| `machine_type` | VM machine type | `e2-micro` |
| `vm_name` | Name of the VM instance | `vulnerable-web-app` |
| `network` | VPC network name | `default` |
| `waf_policy_name` | Cloud Armor policy name | `se-demo-waf-policy` |

## Outputs

After deployment, Terraform provides these outputs:

| Output | Description |
|--------|-------------|
| `load_balancer_ip` | External IP of the load balancer |
| `demo_url` | Full URL to access the demo app |
| `sqli_test_url` | URL to test SQL injection blocking |
| `vm_name` | Name of the deployed VM |
| `waf_policy_name` | Name of the WAF policy |

View outputs anytime with:

```bash
terraform output
```

## Cleanup

**Important:** Destroy the infrastructure when done to avoid ongoing charges.

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.

## Troubleshooting

### 502 Bad Gateway / 404 Not Found
- Wait 5-10 minutes for the load balancer to fully initialize
- Check if the VM startup script completed: `gcloud compute instances get-serial-port-output vulnerable-web-app`

### Connection Refused
- Verify the firewall rule was created: `gcloud compute firewall-rules list`
- Check VM status: `gcloud compute instances list`

### WAF Not Blocking Attacks
- Verify the security policy is attached: `gcloud compute backend-services describe backend-service --global`
- Check Cloud Armor logs in Cloud Console under Security > Cloud Armor
