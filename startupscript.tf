provider "google" {
  credentials = file("../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_compute_network" "vpc" {
  name                    = "cloudassignmentvpc5"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

/** 
Startup Script
**/












