
resource "google_dns_record_set" "frontend" {
  name = "lbdemo.${google_dns_managed_zone.mikesayscode.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.mikesayscode.name

  rrdatas = []
}

resource "google_dns_managed_zone" "mikesayscode" {
  name     = "mikesayscode-zone"
  dns_name = "mikesayscode.com."
}