
resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_sql_server_extended_auditing_policy || var.enable_database_extended_auditing_policy || var.enable_vulnerability_assessment || var.enable_log_monitoring == true ? 1 : 0
  name                      = "saazkpmgdevopslogs${var.environmentName}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "RAGRS"
  min_tls_version           = "TLS1_2"

}
## -------------------------------------------------------------------------------
resource "azurerm_storage_container" "storcont" {
  count                 = var.enable_vulnerability_assessment ? 1 : 0
  name                  = "vulnerability-assessment"
  storage_account_name  = azurerm_storage_account.storeacc.0.name
  container_access_type = "private"
}

resource "random_password" "main" {
  length  = var.password_policy.length
  special = var.password_policy.special
}

resource "azurerm_sql_server" "primary" {
  name                         = "sqlaz-weu-kpmg-devops-${var.environmentName}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "kpmgsqladmin"
  administrator_login_password = random_password.main.result
  // public_network_access = "Disabled"
  
  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "primary" {
  count                                   = var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_sql_server.primary.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = true
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true ? true : false
  // depends_on = [
  //   azurerm_role_assignment.kpmg-devops,
  // ]
}
resource "azurerm_sql_server" "secondary" {
  count                        = var.enable_failover_group ? 1 : 0
  name                         = "sqlaz-weu-kpmg-devops-sec-${var.environmentName}"
  resource_group_name          = var.resource_group_name
  location                     = var.secondary_sql_server_location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.main.result
  
  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "secondary" {
  count                                   = var.enable_failover_group && var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_sql_server.secondary.0.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = true
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true && var.log_analytics_workspace_id != null ? true : null
}
resource "azurerm_sql_database" "db" {
  name                             = var.database_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  server_name                      = azurerm_sql_server.primary.name
  edition                          = var.sql_database_edition
  requested_service_objective_name = var.sqldb_service_objective_name
 
}

resource "azurerm_mssql_database_extended_auditing_policy" "primary" {
  count                                   = var.enable_database_extended_auditing_policy ? 1 : 0
  database_id                             = azurerm_sql_database.db.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true ? true : null
}

#-----------------------------------------------------------------------------------------------
# SQL ServerVulnerability assessment and alert to admin team  - Default is "false"
#-----------------------------------------------------------------------------------------------

resource "azurerm_mssql_server_security_alert_policy" "sap_primary" {
  count                      = var.enable_vulnerability_assessment ? 1 : 0
  resource_group_name          = var.resource_group_name
  
  server_name                = azurerm_sql_server.primary.name
  state                      = "Enabled"
  email_account_admins       = true
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
  storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
}


resource "azurerm_mssql_server_security_alert_policy" "sap_secondary" {
  count                      = var.enable_vulnerability_assessment && var.enable_failover_group ? 1 : 0
  resource_group_name        = var.resource_group_name
  server_name                = azurerm_sql_server.secondary.0.name
  state                      = "Enabled"
  email_account_admins       = true
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
  storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
}

resource "azurerm_mssql_server_vulnerability_assessment" "va_primary" {
  count                           = var.enable_vulnerability_assessment ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_primary.0.id
  storage_container_path          = "${azurerm_storage_account.storeacc.0.primary_blob_endpoint}${azurerm_storage_container.storcont.0.name}/"
  storage_account_access_key      = azurerm_storage_account.storeacc.0.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.email_addresses_for_alerts
  }
}


resource "azurerm_mssql_server_vulnerability_assessment" "va_secondary" {
  count                           = var.enable_vulnerability_assessment && var.enable_failover_group == true ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_secondary.0.id
  storage_container_path          = "${azurerm_storage_account.storeacc.0.primary_blob_endpoint}${azurerm_storage_container.storcont.0.name}/"
  storage_account_access_key      = azurerm_storage_account.storeacc.0.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.email_addresses_for_alerts
  }

} 

resource "azurerm_sql_firewall_rule" "fw01" {
  count               = var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

resource "azurerm_sql_firewall_rule" "fw02" {
  count               = var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.secondary.0.name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

#---------------------------------------------------------
# Azure SQL Failover Group - Default is "false" 
#---------------------------------------------------------

resource "azurerm_sql_failover_group" "fog" {
  count               = var.enable_failover_group ? 1 : 0
  name                = "sqldb-failover-group"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  databases           = [azurerm_sql_database.db.id]
  tags                = merge({ "Name" = format("%s", "sqldb-failover-group") }, var.tags, )

  partner_servers {
    id = azurerm_sql_server.secondary.0.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  readonly_endpoint_failover_policy {
    mode = "Enabled"
  }
}

resource "azurerm_subnet" "snet-ep" {
  count                                          = var.enable_private_endpoint && var.existing_subnet_id == null ? 1 : 0
  name                                           = "snetaz-weu-kpmg-devops-${var.environmentName}-db"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = "vnetaz-weu-kpmg-devops-${var.environmentName}"
  address_prefixes                               = var.private_subnet_address_prefix
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-primary", "sqldb-private-endpoint")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep.0.id : var.existing_subnet_id
  // tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = "sqldbprivatelink-primary"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.primary.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_endpoint" "pep2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = format("%s-secondary", "sqldb-private-endpoint")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep.0.id : var.existing_subnet_id
  // tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = "sqldbprivatelink-secondary"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.secondary.0.id
    subresource_names              = ["sqlServer"]
  }
}

#------------------------------------------------------------------
# DNS zone & records for SQL Private endpoints - Default is "false" 
#------------------------------------------------------------------

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_sql_server.primary]
}

data "azurerm_private_endpoint_connection" "private-ip2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep2.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_sql_server.secondary]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
  
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  virtual_network_id    = var.existing_vnet_id == null ? var.vnet : var.existing_vnet_id
  registration_enabled  = true
  
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.primary.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}

resource "azurerm_private_dns_a_record" "arecord2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.secondary.0.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip2.0.private_service_connection.0.private_ip_address]

}

# Monitoring----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  // count                      = var.enable_log_monitoring 
  name                       = lower("extaudit-${var.database_name}-diag")
  target_resource_id         = azurerm_sql_database.db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id != null ? var.storage_account_id : null

  dynamic "log" {
    for_each = var.extaudit_diag_logs
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}