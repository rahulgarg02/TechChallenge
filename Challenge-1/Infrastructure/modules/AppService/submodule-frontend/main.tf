
resource "azurerm_app_service_plan" "example1" {
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
  target_resource_id  = azurerm_app_service_plan.example1.id

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
        metric_resource_id = azurerm_app_service_plan.example1.id
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
        metric_resource_id = azurerm_app_service_plan.example1.id
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
        metric_resource_id = azurerm_app_service_plan.example1.id
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
        metric_resource_id = azurerm_app_service_plan.example1.id
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
resource "azurerm_app_service" "example1" {
  name                       = azurerm_app_service_plan.example1.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.example1.id
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
    // pre_warmed_instance_count = var.pre_warmed_instance_count
    linux_fx_version = "NODE|14-lts"
    ftps_state = "Disabled"
    http2_enabled = true
    python_version = "3.4"
    php_version = "7.4"
    dotnet_framework_version = "v6.0"

    cors {
      allowed_origins = ["*"]
    }
  }
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_app_service_slot" "example1" {
  name                = "deploymentslot"
  app_service_name    = azurerm_app_service.example1.name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example1.id
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
    
    linux_fx_version = "NODE|14-lts"
    ftps_state = "Disabled"
    http2_enabled = true
    python_version = "3.4"
    php_version = "7.4"
    dotnet_framework_version = "v6.0"

    cors {
      allowed_origins = ["*"]
    }
  }

    identity {
    type = "SystemAssigned"
  }

}