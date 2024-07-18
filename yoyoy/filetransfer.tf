/*
provider "google" {
  credentials = file("../../gcpkey/newKey2/project4-414017-f35db3a91268.json")
  project     = "project4-414017"
  region      = "us-east4"
}

resource "google_storage_bucket" "bucket_pranavdhongade_project4-414017" {
  name     = "test-bucket_pranavdhongade_project4-414017"
  location = "US"
}

resource "local_file" "rendered_template" {
  content  = templatefile("./function-source/index-template.js", { IP_ADDRESS = "0.0.0.0" })
  filename = "./function-source/index-template.js"
}

data "archive_file" "function_source_zip" {
  type        = "zip"
  output_path = "./function-source.zip"
  source_dir  = "./function-source"
   depends_on = [local_file.rendered_template]
}

resource "google_storage_bucket_object" "archive_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket_pranavdhongade_project4-414017.name
  source = data.archive_file.function_source_zip.output_path
  depends_on = [google_storage_bucket.bucket_pranavdhongade_project4-414017]
}
*/