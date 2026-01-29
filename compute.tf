# VM Instance running the vulnerable Python Flask application

resource "google_compute_instance" "web_server" {
  name         = var.vm_name
  machine_type = var.machine_type
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = var.network
    access_config {
      # Ephemeral public IP
    }
  }

  # Startup script to install Flask and run the vulnerable demo app
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip
    pip3 install Flask

    # Create a simple, intentionally vulnerable Flask app
    cat > /app.py <<APP_EOF
from flask import Flask, request

app = Flask(__name__)

@app.route('/')
def home():
    # VULNERABILITY: Reflecting user input directly without sanitization
    user_input = request.args.get('query', '')
    return f"<h1>Welcome to the WAF Demo App</h1><p>You searched for: {user_input}</p><p>(Try adding ?query=' OR 1=1 -- to the URL)</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
APP_EOF

    # Run the app
    python3 /app.py
  EOF
}
