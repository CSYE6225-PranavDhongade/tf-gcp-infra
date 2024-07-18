/*
provider "google" {
  credentials = file("../../gcpkey/newKey2/project4-414017-f35db3a91268.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_project_iam_binding" "loggingbinder" {
  project = "project4-414017"
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = "project4-414017"
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "monitoringmetricwriter" {
  project = "project4-414017"
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]

  depends_on = [google_service_account.service_account]
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

  target_service_accounts = ["cloudass4serviceaccount@project4-414017.iam.gserviceaccount.com",
  "${google_service_account.service_account.email}"]

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
    tier = "db-custom-2-7680"
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
  override_special = "#-"
}

resource "google_sql_user" "users" {
  name     = "webapp"
  instance = google_sql_database_instance.main.name
  password = random_password.password.result
}

resource "google_compute_global_address" "lb_1" {
  name = "l7-xlb-static-ip"
  purpose = "loadbalance_forwarding"
  address_type  = "EXTERNAL"
}

# Forwarding rule for HTTP
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "l7-xlb-forwarding-rule-http"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.lb_1.address

  depends_on = [
    google_compute_global_address.lb_1
  ]
}

# Http proxy
resource "google_compute_target_https_proxy" "default" {
  name     = "l7-xlb-target-http-proxy"
  url_map  = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.managed_ssl_cert.id]

  depends_on = [
    google_compute_managed_ssl_certificate.managed_ssl_cert
  ]
}

resource "google_compute_managed_ssl_certificate" "managed_ssl_cert" {
  name = "managed-ssl-cert"

  managed {
    domains = ["allgoodtech.me"]
  }
}

# url map
resource "google_compute_url_map" "default" {
  name            = "l7-xlb-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_backend_service" "default" {
  name                    = "l7-xlb-backend-service"
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  health_checks           = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Health check
resource "google_compute_health_check" "default" {
  name     = "l7-xlb-hc"
  http_health_check {
    port = 3000
    request_path = "/healthz"
  }
}

resource "google_compute_instance_group_manager" "default" {
  name     = "l7-xlb-mig1"
  zone     = "us-east4-b"
  named_port {
    name = "http"
    port = 3000  # Adjust to match your application's actual port
  }
  version {
    instance_template = google_compute_instance_template.example_instance.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size = 1
}

resource "google_compute_instance_template" "example_instance" {
  name = "instance-20240328-182157"
  description = "This template is used to create app server instances."
  machine_type = "e2-medium"

  metadata_startup_script = <<-EOF
  #!/bin/bash

  # Create an empty .env file in the root directory

  touch  /opt/csye6225/webapp/config/.env

  # Add content to the .env file
  cat <<EOL > /opt/csye6225/webapp/config/.env
DB_HOST=${google_sql_database_instance.main.private_ip_address}
DB_USER=${google_sql_user.users.name}
DB_PASS=${google_sql_user.users.password}
DB_NAME='webapp'
DB_PORT=5432
  EOL

  #sudo -i

  #sudo chown -R postgres /opt/csye6225

  #sudo -i -u postgres

  #cd /opt/csye6225/webapp

  #sudo npm install dotenv

  #cd

  #sudo -i -u postgres

  sudo systemctl restart bootup

  EOF

  // Create a new boot disk from an image
  disk {
    source_image      = "projects/project4-414017/global/images/centos-stream9-1718918126"
    auto_delete       = true
    boot        = true
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet1.self_link
    access_config {
      // No need to specify anything here for ephemeral IP assignment
    }
  }

  depends_on = [
    google_service_account.service_account
  ]

  service_account {
    email  = "${google_service_account.service_account.email}"
    scopes = ["cloud-platform"]
  }
}

resource "google_dns_record_set" "a_record" {
  name         = "allgoodtech.me."
  type         = "A"
  ttl          = 300
  managed_zone = "cloudzone1"

  rrdatas = [google_compute_global_address.lb_1.address]

  depends_on = [google_compute_global_address.lb_1]
}

resource "google_compute_autoscaler" "default" {
  name   = "my-autoscaler"
  zone   = "us-east4-b"
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.05  # 5% CPU utilization
    }
  }
}
*/