
variable "environmentName" {}
variable "password" {}
// variable "apimip" {
    
// }
variable "resource_group_name" {}
variable "location" {}
variable "function_app_properties" {}
// variable "mssql" {
//       type        = string
// }
// variable "storageAccount" {
//     default = null
// }
variable "function_sku" {}
variable "function_kind" {}
variable "fnreserved" {}
variable "key_vault" {}
variable "appservicesubnet" {}
variable "pre_warmed_instance_count" {
    default = null
}
variable "always_on" {
    default = true
}


