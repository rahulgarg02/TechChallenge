


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "kvaz-weu-kpmg-devops${var.environmentName}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

      network_acls {
        bypass = "AzureServices"
        default_action = "Deny"
    }
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.example.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}


// resource "azurerm_key_vault_secret" "example" {
//   name         = "sqldatabase"
//   value        = var.dbcreds
//   key_vault_id = azurerm_key_vault.example.id
// }
