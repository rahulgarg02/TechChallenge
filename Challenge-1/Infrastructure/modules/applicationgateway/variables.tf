variable "resource_group_name" {}
variable "location" {}
variable "environmentName" {
    
}
variable "subnet" {}
variable "publicip" {}
variable "vnet" {}

// Optional
variable "backend_address_pools" {
  description = "List of backend address pools."
  type = list(object({
    name         = string
    // ip_addresses = list(string)
    fqdns        = list(string)
  }))
  default = [

  ]
}
variable "backend_http_settings" {
  description = "List of backend HTTP settings."
  type = list(object({
    name            = string
    path            = string
    is_https        = bool
    request_timeout = string
    probe_name      = string
  }))
  default = [

  ]
}
variable "http_listeners" {
  description = "List of HTTP/HTTPS listeners. HTTPS listeners require an SSL Certificate object."
  type = list(object({
    name                 = string
    ssl_certificate_name = string
    host_name            = string
    require_sni          = bool
  }))
  default = [

  ]
}
variable "basic_request_routing_rules" {
  description = "Request routing rules to be used for listeners."
  type = list(object({
    name                        = string
    http_listener_name          = string
    backend_address_pool_name   = string
    backend_http_settings_name  = string
  }))
  default = []
}


variable "sku_name" {
  description = "Name of App Gateway SKU. Options include Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2"
  default     = "Standard_v2"
}
variable "sku_tier" {
  description = "Tier of App Gateway SKU. Options include Standard, Standard_v2, WAF and WAF_v2"
  default     = "Standard_v2"
}
variable "probes" {
  description = "Health probes used to test backend health."
  default     = []
  type = list(object({
    name                                      = string
    path                                      = string
    is_https                                  = bool
  }))
}

variable "publicipname" {
  description = "Domain name label for Public IP created."
  
}

variable "ips_allowed" {
  description = "A list of IP addresses to allow to connect to App Gateway."
  default     = []
  type = list(object({
    name         = string
    priority     = number
    ip_addresses = string
  }))
}



variable "ssl_certificates" {
  description = "SSL Certificate objects to be used for HTTPS listeners. Requires a PFX certificate stored on the machine running the Terraform apply."
  default     = []
  type = list(object({
    name              = string
    pfx_cert_filepath = string
    pfx_cert_password = string
  }))
}