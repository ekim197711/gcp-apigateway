variable "project_name" {
  default = "mikes-demo2023"
  type    = string
}

variable "openapi_template_vars" {
  type = object({
    var1 : string
    var2 : string
  })
}

variable "region" {
  type = string
}

variable "services-to-enable" {
  type    = set(string)
  default = ["apigateway.googleapis.com"]
}