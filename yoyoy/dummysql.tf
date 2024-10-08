/*
resource "google_sql_database_instance" "sql_instance_terraform" {
  name                = var.sql_instance_name
  region              = var.region
  database_version    = var.db_version
  deletion_protection = var.del_proctection-rule
  depends_on          = [google_service_networking_connection.private_vpc_connection_terraform]

  settings {
    tier              = var.db_machine_type
    availability_type = var.routing_mode
    disk_autoresize   = var.autoresize
    disk_size         = var.disksize
    disk_type         = var.disktype

    backup_configuration {
      enabled            = true
      binary_log_enabled = true

    }

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enable
      private_network                               = google_compute_network.terraform_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
    encryption_key_name = google_kms_crypto_key.terraform_sql_key.id
}

resource "google_project_service_identity" "cloud_sql_service_identity" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project = var.project_id
}

resource "google_kms_crypto_key_iam_binding" "sql_crpyto_key_service" {
  crypto_key_id = google_kms_crypto_key.terraform_sql_key.id
  role          = var.kms_role

  members = [
    "serviceAccount:${google_project_service_identity.cloud_sql_service_identity.email}",
  ]
}
*/