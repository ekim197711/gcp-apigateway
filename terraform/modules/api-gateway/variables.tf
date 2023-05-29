variable "project_name" {
  default = "mikes-demo2023"
  type    = string
}

variable "openapi_template_vars" {
  type = object({
    variable1 : string
    anothervar : string
  })
}