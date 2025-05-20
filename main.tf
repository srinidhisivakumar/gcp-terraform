provider "google" {
  project = var.project_id
  region  = var.region
}

# Static Website Bucket
resource "google_storage_bucket" "website_bucket" {
  name                        = var.bucket_name
  location                    = var.region
  force_destroy               = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  uniform_bucket_level_access = true
}

# Public access to objects
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}

# DNS Managed Zone
resource "google_dns_managed_zone" "portfolio_zone" {
  name     = "portfolio-zone"
  dns_name = "srinidhisivakumar.com."
  dnssec_config {
    state = "off"
  }
}

# CNAME Record: www -> GCS site
resource "google_dns_record_set" "www_record" {
  name         = "www.srinidhisivakumar.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.portfolio_zone.name
  rrdatas      = ["c.storage.googleapis.com."]
}

output "bucket_url" {
  value = "http://${google_storage_bucket.website_bucket.name}.storage.googleapis.com"
}

output "dns_name_servers" {
  value = google_dns_managed_zone.portfolio_zone.name_servers
}

