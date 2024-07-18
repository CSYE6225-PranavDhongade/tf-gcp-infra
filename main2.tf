/*
provider "google" {
  credentials = file("../gcpkey/project4-414017-5c44874f2950.json")
  project     = "project4-414017"
  region      = "us-east4"
}

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

    subnetwork = "projects/project4-414017/regions/us-east4/subnetworks/webapproute"
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
