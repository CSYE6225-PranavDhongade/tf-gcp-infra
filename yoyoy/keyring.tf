/*
provider "google" {
  credentials = file("../../gcpkey/newKey2/project4-414017-f35db3a91268.json")
  project     = "project4-414017"
  region      = "us-east4"
}


resource "google_kms_key_ring" "my_key_ring1" {
  name     = "my-key-ring"
  location = "us-east4"
}

resource "google_kms_crypto_key" "vm_key" {
  name     = "vm-key"
  key_ring = google_kms_key_ring.my_key_ring.id
  purpose  = "ENCRYPT_DECRYPT"
  rotation_period = "2592000s" # 30 days in seconds

  lifecycle {
    prevent_destroy = true
  }
}
*/