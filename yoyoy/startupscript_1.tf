/*
provider "google" {
  credentials = file("../../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_compute_network" "vpc" {
  name                    = "cloudassignmentvpc4"
  auto_create_subnetworks = false
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

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network = google_compute_network.vpc.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_compute_global_address.private_ip_address]
}

resource "google_sql_database_instance" "main" {
  name             = "main-instance"
  database_version = "POSTGRES_14"
  region           = "us-east4"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    deletion_protection_enabled = false
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }
    availability_type = "REGIONAL"
    disk_type = "PD_SSD"
    disk_size = 100
  }
}

resource "google_sql_database" "database" {
  name     = "webapp"
  instance = google_sql_database_instance.main.name
  depends_on = [google_sql_database_instance.main]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.main.name
  password = random_password.password.result
}

resource "null_resource" "generate_env_file" {
  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash

      cat > .env << 'END_OF_THE_WORLD'
      DB_HOST = ${google_sql_database_instance.main.private_ip_address}
      DB_USER = ${google_sql_user.users.name}
      DB_PASS = ${google_sql_user.users.password}
      DB_NAME = 'cloudassignmentdatabase'
      DB_PORT = 5432

      # Check if the content was written successfully
      if [ $? -ne 0 ]; then
        echo "Failed to write to .env file"
        exit 1
      fi

      actual_content=$(cat /opt/csye6225/webapp/config/.env)

      if [ "$expected_content" != "$actual_content" ]; then
        echo "Content of .env file is not as expected"
        exit 1
      fi

      END_OF_THE_WORLD
    EOT

    interpreter = ["bash", "-c"]
  }
}

# Define the VM instance
resource "google_compute_instance" "example_instance" {
  name         = "instance-20240328-182154"
  machine_type = "e2-medium"
  zone         = "us-east4-b"

  boot_disk {
    initialize_params {
      image = "projects/project4-414017/global/images/centos-stream8-1710985162"
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

  depends_on = [google_compute_global_address.private_ip_address]
}
*/