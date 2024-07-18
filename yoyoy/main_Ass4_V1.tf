
/*
provider "google" {
  credentials = file("../../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_compute_network" "vpc" {
  name                    = "cloudassignmentvpc4"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "webapp_subnet1" {
  name          = "webapp1"
  ip_cidr_range = "10.0.5.0/24"
  network       = google_compute_network.vpc.self_link
  region        = "us-east4"
}

resource "google_compute_route" "webapp_route" {
  name             = "webapp-route2"
  network          = google_compute_network.vpc.self_link
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway" # Assuming you've defined this elsewhere
  priority         = 1000
  tags             = ["webapp1"]
}

resource "google_compute_firewall" "allow_app_traffic" {
  name    = "example-firewall"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "all"
  }

  target_service_accounts = ["cloudass4serviceaccount@project4-414017.iam.gserviceaccount.com"]

  source_ranges = ["0.0.0.0/0"] # You may want to restrict this to specific IP ranges for security purposes
}

resource "google_compute_instance" "example_instance" {
  name         = "instance-20240328-182154"
  machine_type = "e2-medium"
  zone         = "us-east4-b"

metadata_startup_script = <<-EOF
#!/bin/bash

# Create an empty .env file in the root directory

touch  /opt/csye6225/webapp/config/.env

# Add content to the .env file
cat <<EOL > /opt/csye6225/webapp/config/.env
DB_HOST='localhost'
DB_USER='postgres'
DB_PASS='root'
DB_NAME='cloudassignmentdatabase'
DB_PORT=5432
EOL

sudo su

cd /opt/csye6225/webapp

sudo npm install dotenv

cd

sudo chown -R csye6225:csye6225 /opt/csye6225/webapp
sudo chmod -R 750 /opt/csye6225/webapp

sudo systemctl restart bootup

EOF
  
  boot_disk {
    initialize_params {
      image = "projects/project4-414017/global/images/centos-stream8-1716322291"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet1.self_link
    access_config {
      // No need to specify anything here for ephemeral IP assignment
    }
  }

  service_account {
    email  = "cloudass4serviceaccount@project4-414017.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
*/