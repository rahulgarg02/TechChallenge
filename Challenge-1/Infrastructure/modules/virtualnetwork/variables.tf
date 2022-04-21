variable "resource_group_name" {}
variable "location" {}
variable "environmentName" {
    
}

variable "domain_name_label" {
  description = "Domain name label for Public IP created."
  default = null
}


variable "sku_tier" {
  description = "Tier of App Gateway SKU. Options include Standard, Standard_v2, WAF and WAF_v2"
  default     = "Standard_v2"
}