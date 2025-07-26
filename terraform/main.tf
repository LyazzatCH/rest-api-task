provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "firestore_api" {
  service = "firestore.googleapis.com"
}

resource "google_project_service" "cloudfunctions_api" {
  service = "cloudfunctions.googleapis.com"
}

resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-bucket"
  location = var.region
}

resource "google_cloudfunctions2_function" "api_function" {
  name        = "rest-api-function"
  location    = var.region
  description = "REST API handler"
  build_config {
    runtime     = "python310"
    entry_point = "my-flask-api"
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.source_archive.name
      }
    }
  }
  service_config {
    min_instance_count = 0
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_storage_bucket_object" "source_archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/../function-source.zip"
}
