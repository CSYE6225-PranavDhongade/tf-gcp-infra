provider "google" {
  credentials = file("../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east1"
}

resource "google_compute_network" "vpc" {
  count                   = var.vpc_count
  name                    = "cloudassignmentvpc${count.index + 1}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "webapp_subnet" {
  count         = var.vpc_count
  name          = "webapp-${count.index + 1}"
  ip_cidr_range = "10.${count.index + 1}.0.0/24"
  network       = google_compute_network.vpc[count.index].self_link
  region        = "us-east1"
}

resource "google_compute_subnetwork" "db_subnet" {
  count         = var.vpc_count
  name          = "db-${count.index + 1}"
  ip_cidr_range = "10.${count.index + 1}.1.0/24"
  network       = google_compute_network.vpc[count.index].self_link
  region        = "us-east1"
}

resource "google_compute_route" "webapp_route" {
  count            = 
  name             = "webapp-route-${count.index + 1}"
  network          = google_compute_network.vpc[count.index].self_link
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway" # Assuming you've defined this elsewhere
  priority         = 1000
  tags             = ["webapp"]
}