/*
provider "google" {
  credentials = file("../../gcpkey/newKey2/project4-414017-f35db3a91268.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_pubsub_topic" "verify_email" {
  name = "verify_email"
  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = "verify_email_subscription"
  topic = google_pubsub_topic.verify_email.name
}
*/