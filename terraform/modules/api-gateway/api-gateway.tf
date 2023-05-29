resource "google_api_gateway_api" "_api_gateway_api" {
  provider     = google-beta
  api_id       = "api-gateway"
  display_name = "api-gateway"
}

resource "random_id" "rng" {
  keepers = {
    first = "${timestamp()}"
  }
  byte_length = 8
}

resource "google_service_account" "mikes_api_gateway" {
  account_id   = "mikes-api-gateway-client"
  display_name = "mikes api gateway client"
}

resource "google_project_service" "service_api_gateway_enable" {
  project = var.project_name
  service = google_api_gateway_api._api_gateway_api.managed_service
}

resource "google_project_iam_member" "mikes_client_cloud_run_invoke" {
  project = "${var.project_name}"
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.mikes_api_gateway.account_id}@${var.project_name}.iam.gserviceaccount.com"
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  api           = google_api_gateway_api._api_gateway_api.api_id
  api_config_id = "config-${replace(lower(random_id.rng.id),"_","-")}"
  gateway_config {
    backend_config {
      google_service_account = google_service_account.mikes_api_gateway.name
    }
  }
  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = base64encode(templatefile("${path.module}/openapi/openapi.yaml", var.openapi_template_vars))
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gateway_gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_cfg.name
  gateway_id = "api-gateway"
}
