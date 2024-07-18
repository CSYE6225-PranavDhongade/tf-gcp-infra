/*
provider "google" {
  credentials = file("../../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_sql_database" "database" {
  name     = "webapp"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database_instance" "main" {
  name             = "main-instance"
  database_version = "POSTGRES_14"
  region           = "us-east4"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    deletion_protection_enabled = false
    availability_type = "REGIONAL"
    disk_type = "PD_SSD"
    disk_size = 100
  }
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
      DB_HOST = ${google_sql_user.users.name}
      DB_USER = ${google_sql_user.users.name}
      DB_PASS = ${google_sql_user.users.password}
      DB_NAME = 'cloudassignmentdatabase'
      DB_PORT = 5432

      END_OF_THE_WORLD
    EOT

    interpreter = ["bash", "-c"]
  }
}

*/



