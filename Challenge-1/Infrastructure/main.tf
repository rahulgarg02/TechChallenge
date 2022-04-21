
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  version = "~>2.97.0"
  features {}
  skip_provider_registration = true
}

locals {
  ui-beap       = "ui-beap"
  cdn-beap      = "cdn-beap"
  ui-htst       = "ui-htst"
  cdn-htst      = "cdn-htst"
  http-listener = "http-listener"
  http-url-path = "http-url-path"
}
## ---------- Create Resource group -------------##
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.tags
}

## ---------- Create logging monitoring (Log Analystics and App Insights) for Azure resourcs -------------##
resource "azurerm_log_analytics_workspace" "example" {
  name                = "lawsaz-weu-kpmg-devops-${var.environmentName}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags     = var.tags
}

resource "azurerm_application_insights" "example" {
  name                = "ainsaz-weu-kpmg-devops-${var.environmentName}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.example.id
  retention_in_days   = "90"
  tags     = var.tags
}

 ####--------------------------- CDN for static content delivery from blob storage ------------#a##

module "cdn" {
   source              = "./modules/cdn"
  
   environmentName     = var.environmentName
   resource_group_name = azurerm_resource_group.example.name
   location            = var.fn_location
 }
### -------------- Virtual Network to place Backend, Frontend , Database and App Gateway components inside that ---------#####
module "vnet" {
  source            = "./modules/virtualnetwork"
  environmentName   = var.environmentName
  resource_group_name = azurerm_resource_group.example.name
  location  = var.fn_location

}

## -------------------- Azure API management for Backend components --------------###
module "apim" {
  source              = "./modules/apiManagement"
  // project             = var.project
  environmentName     = var.environmentName
  resource_group_name = azurerm_resource_group.example.name
  location            = var.fn_location
  publisher           = var.apim_publisher
  apim_sku            = var.apim.apim_sku
  key_vault           = module.keyVault.key_vault
  subnet              = module.vnet.subnet1
  
  resourceid          = azurerm_application_insights.example.id
  instrumentation_key = azurerm_application_insights.example.instrumentation_key
  
}
## ----------------- Azure application gateway configuration for end users --------#######

module "applicationgateway" {
   source              = "./modules/applicationgateway"
  
   environmentName     = var.environmentName
   resource_group_name = azurerm_resource_group.example.name
   location            = var.fn_location
   vnet                =  module.vnet.vnetwork
   subnet              = module.vnet.subnet.id
   publicipname        = module.vnet.publicip.name
   publicip            = module.vnet.publicip.id
   backend_address_pools = [
    {
      name  = local.ui-beap
      // ip_addresses = null
      fqdns = ["apimaz-weu-kpmg-devops-bff-${var.environmentName}.azure-api.net"]

    },
    {
      name  = local.cdn-beap
      // ip_addresses = null
      fqdns = ["cdnaz-weu-kpmg-devops-${var.environmentName}.azureedge.net"]
    }
  ]

  backend_http_settings = [
    {
      name = local.ui-htst
      path = "/"
      is_https = true
      request_timeout = 30
      probe_name = null
    }
  ]

  http_listeners = [
    {
      name                 = local.http-listener
      ssl_certificate_name = "kpmg"
      host_name            = var.fehost
      require_sni          = true
  
    }
  ]
  ssl_certificates = [{
    name     = "kpmg"
    pfx_cert_filepath     = var.pfxfile
    pfx_cert_password = var.pfxpwd
  }]
  
  basic_request_routing_rules = [
    {
         name               = "http-rqrt"
         http_listener_name = local.http-listener
         backend_address_pool_name  = local.ui-beap
        backend_http_settings_name = local.ui-htst
                 

    }
  ]
  
 }

 # --------- Storage account for static contents, files or logs ---------------------##
module "storageAccount" {
  source               = "./modules/storageAccount"
  
  environmentName      = var.environmentName
  resource_group_name  = azurerm_resource_group.example.name
  location             = var.fn_location
  storage_account_tier = var.storage_account_tier
  storage_account_type = var.storage_account_type
}

##-------------- Azure sql database -------------------- ###
module "database" {
  source              = "./modules/database"
 
  environmentName     = var.environmentName
  resource_group_name = azurerm_resource_group.example.name
  location            = var.fn_location
  password_policy     = var.password_policy
  enable_database_extended_auditing_policy = var.enable_database_extended_auditing_policy
  enable_sql_server_extended_auditing_policy = var.enable_sql_server_extended_auditing_policy
  enable_threat_detection_policy = var.enable_threat_detection_policy
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  vnet                       = module.vnet.vnetworkid
}

########## ------------------------Key vault to store  app secret parameters ---------------##
module "keyVault" {
  source              = "./modules/keyVault"
  
  environmentName     = var.environmentName
  resource_group_name = azurerm_resource_group.example.name
  location            = var.fn_location
  // dbcreds              = var.fnKeys
  
}
## ------- Frontend and Backend app service for application deployment ------------##
module "functionApps" {
  source              = "./modules/AppService"

  environmentName     = var.environmentName
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  instrumentation_key      = azurerm_application_insights.example.instrumentation_key
  function_sku  = var.function_sku
  function_sku1  = var.function_sku1
  function_kind = var.function_kind
  fn_location   = var.fn_location
  fnreserved    = var.fnreserved
  storageAccount = module.storageAccount.functionAppStorage
  subnetbe = module.vnet.subnetbe.id
  subnetbe1 = module.vnet.subnetbe1.id
  subnetbe2 = module.vnet.subnetbe2.id
  mssql = module.database.connection_details
  key_vault = module.keyVault.key_vault


}


output "mssql" {
  value = module.database.connection_details
}

output "apim" {
  value = module.apim.api_management_public_ip_addresses
}