resource "azurerm_app_service_plan" "example" {
  name                = "wapaz-weu-kpmg-devops-${var.function_app_properties.name}-${var.environmentName}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.function_kind
  
  reserved            = var.fnreserved  
  sku {
    tier = var.function_sku.tier
    size = var.function_sku.size
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  name                = "${var.function_app_properties.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  target_resource_id  = azurerm_app_service_plan.example.id

  profile {
    name = "CpuProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Maximum"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = azurerm_app_service_plan.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Maximum"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = azurerm_app_service_plan.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "lessThan"
        threshold          = 60
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    
     rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "lessThan"
        threshold          = 60
      }

      scale_action {
        direction = "decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
resource "azurerm_app_service" "example" {
  name                       = azurerm_app_service_plan.example.name
  location                   = var.location
  
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  app_settings               = var.function_app_properties.appSettings
  client_cert_enabled = false
  logs {
    http_logs {
      file_system {
        retention_in_days = 4
        retention_in_mb  = 25
      }
	}
    failed_request_tracing_enabled = true
    detailed_error_messages_enabled = true
  }
  auth_settings {
    enabled = false
  }
  https_only                 = true
  site_config {
    always_on                 = var.function_sku.tier == "ElasticPremium" ? false : var.always_on
    dotnet_framework_version = "v6.0"
    ftps_state = "Disabled"
    http2_enabled = true
    php_version = "7.4"
    python_version = "3.4"

 
    cors {
      allowed_origins = ["*"]
    }
  }

  identity {
    type = "SystemAssigned"
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=sqlaz-weu-kpmg-devops-${var.environmentName}.database.windows.net;Database=UserStore;User Id=mvpsqladmin; Password=${var.password};MultipleActiveResultSets=true"
  }
}


resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.example.id
  subnet_id      = var.appservicesubnet
}

resource "azurerm_app_service_slot" "example" {
  name                = "deploymentslot"
  app_service_name    = azurerm_app_service.example.name
  location            = var.location
  
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id
  app_settings        = var.function_app_properties.appSettings
  logs {
    http_logs {
      file_system {
        retention_in_days = 4
        retention_in_mb  = 25
      }
	}
    failed_request_tracing_enabled = true
    detailed_error_messages_enabled = true
  }
  auth_settings {
    enabled = false
  }
  https_only                 = true
  site_config {
    always_on                 = var.function_sku.tier == "ElasticPremium" ? false : var.always_on
    
    dotnet_framework_version = "v6.0"
    ftps_state = "Disabled"
    http2_enabled = true
    php_version = "7.4"
    python_version = "3.4"

    
    cors {
      allowed_origins = ["*"]
    }
  }

  identity {
    type = "SystemAssigned"
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=sqlaz-weu-kpmg-devops-${var.environmentName}.database.windows.net;Database=UserStore;User Id=mvpsqladmin; Password=${var.password};MultipleActiveResultSets=true"
  }
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = var.key_vault.id

  tenant_id = azurerm_app_service.example.identity[0].tenant_id
  object_id = azurerm_app_service.example.identity[0].principal_id

  secret_permissions = [
    "get",
  ]
}
