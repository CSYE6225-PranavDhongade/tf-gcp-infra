/*
provider "google" {
  credentials = file("../../gcpkey/newKey2/project4-414017-f35db3a91268.json")
  project     = "project4-414017"
  region      = "us-east4"
}

data "google_kms_key_ring" "my_key_ring" {
  name     = "my-key-ring"
  location = "us-east4"
}

data "google_kms_crypto_key" "sqlInstance_key1" {
  name     = "sqlInstance-key1"
  key_ring = data.google_kms_key_ring.my_key_ring.id
}

resource "google_project_service_identity" "cloudsql_sa" {
  provider = google-beta

  project = "cool-project"
  service = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = data.google_kms_crypto_key.sqlInstance_key1.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
   "serviceAccount:${google_project_service_identity.cloudsql_sa.email}"
  ]
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
  encryption_key_name = data.google_kms_crypto_key.sqlInstance_key1.id
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
*/