
variable "environmentName" {}
variable "resource_group_name" {}
variable "location" {}

variable "tags" {
  type = map(string)
  default = {
    "createdBy" = "Devops"
  }
}
