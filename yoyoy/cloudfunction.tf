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

resource "google_storage_bucket" "bucket_pranavdhongade_project4-414017" {
  name     = "test-bucket_pranavdhongade_project4-414017"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket_pranavdhongade_project4-414017.name
  source = "./function-source.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "My function"
  runtime     = "nodejs16"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket_pranavdhongade_project4-414017.name
  source_archive_object = google_storage_bucket_object.archive.name
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.verify_email.name
  }
  entry_point           = "helloPubSub"
}
*/