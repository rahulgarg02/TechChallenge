
variable "environmentName" {}
variable "resource_group_name" {}
variable "location" {}
variable "function_app_properties" {}

variable "function_sku" {}

variable "function_kind" {}
variable "fnreserved" {}
variable "key_vault" {}
variable "pre_warmed_instance_count" {
    default = null
}
variable "always_on" {
    default = true
}


