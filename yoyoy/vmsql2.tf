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

resource "google_kms_crypto_key" "key" {
  name     = "crypto-key-name5"
  key_ring = data.google_kms_key_ring.my_key_ring.id
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_compute_network" "vpc" {
  name = "cloudassignmentvpc4"
  auto_create_subnetworks = false
}

resource "google_project_service_identity" "cloudsql_sa" {
  provider = google-beta
  project = "project4-414017"
  service = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.key.id
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
   "serviceAccount:${google_project_service_identity.cloudsql_sa.email}"
  ]

  depends_on = [google_kms_crypto_key.key, google_project_service_identity.cloudsql_sa]
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
  encryption_key_name = google_kms_crypto_key.key.id
  depends_on = [google_service_networking_connection.private_vpc_connection, google_kms_crypto_key_iam_binding.crypto_key]
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
*/