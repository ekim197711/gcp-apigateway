locals {
  region                = "europe-west2"
  project_name          = "mikes-demo2023"
  openapi_template_vars = {
    var1 = ""
    var2 = ""
  }
}

module "api-gateway" {
  source                = "../../modules/api-gateway"
  region                = local.region
  project_name          = local.project_name
  openapi_template_vars = local.openapi_template_vars
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

  }
}

provider "google" {
  project = local.project_name
  region  = local.region
}

provider "google-beta" {
  project = local.project_name
  region  = local.region
}

terraform {
  backend "gcs" {
    bucket = "mikes-demo2023-terraform-states"
    prefix = "api-gateway"
  }
}

provider "random" {
}

