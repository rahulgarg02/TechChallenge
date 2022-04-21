
locals {
  environmentName                                = title(var.environmentName)

  commonConfig = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${var.instrumentation_key}"
     
  }

  customConfig = {
    # "ENVIRONMENT" = local.environmentName # Dev/Test/Stage
  }
}

module "Appservice0" {
  source = "./submodule-backend"
  environmentName     = var.environmentName
  resource_group_name = var.resource_group_name
  appservicesubnet    = var.subnetbe
  location            = var.fn_location
  function_app_properties = {
    "name" = "be"
    "appSettings" = merge(
      // var.fnKeys,
      merge(
        local.commonConfig,
        {
     })
    )
  }
  
  function_sku              = var.function_sku
  function_kind             = var.function_kind
  key_vault                 = var.key_vault
  fnreserved                = "false"
  password                  = var.mssql.UserStore.password 
  pre_warmed_instance_count = var.environmentName == "" || var.environmentName == "" ? 10 : null
}

module "Appservice1" {
  source = "./submodule-backend"
  environmentName     = var.environmentName
  appservicesubnet    = var.subnetbe1
  resource_group_name = var.resource_group_name
  location            = var.fn_location
  function_app_properties = {
    "name" = "be1"
    "appSettings" = merge(
      
      merge(
        local.commonConfig,
        {
    
      })
    )
  }
  
  function_sku              = var.function_sku
  function_kind             = var.function_kind
  key_vault                 = var.key_vault
  fnreserved                = "false"
  password                  = var.mssql.UserStore.password
  pre_warmed_instance_count = var.environmentName == "" || var.environmentName == "" ? 10 : null
}
module "Appservice2" {
  source = "./submodule-backend"
  environmentName     = var.environmentName
  appservicesubnet    = var.subnetbe2
  resource_group_name = var.resource_group_name
  location            = var.fn_location
  function_app_properties = {
    "name" = "be2"
    "appSettings" = merge(     
      merge(
        local.commonConfig,
        {
        
      })
    )
  } 
  function_sku              = var.function_sku
  function_kind             = var.function_kind
  key_vault                 = var.key_vault
  fnreserved                = "false"
  password                  = var.mssql.UserStore.password
  
  
  pre_warmed_instance_count = var.environmentName == "" || var.environmentName == "" ? 10 : null
}

module "AppService3" {
  source = "./submodule-frontend"
  environmentName     = var.environmentName
  resource_group_name = var.resource_group_name
  location            = var.fn_location
  
  function_app_properties = {
    "name" = "frontend"
    "appSettings" = merge(
    
      merge(
        local.commonConfig,
        {
          
      })
    )
  }  
  function_sku              = var.function_sku1
  function_kind             = "Linux"
  key_vault                 = var.key_vault
  fnreserved                = "true"
  pre_warmed_instance_count = var.environmentName == "" || var.environmentName == "" ? 10 : null
}
