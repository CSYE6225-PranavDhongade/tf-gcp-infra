/*
provider "google" {
  credentials = file("../gcpkey/project4-414017-5c44874f2950.json")
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
*/
