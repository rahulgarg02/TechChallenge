
# ------------------------------------logicapp-----------------------------------------
resource "azurerm_storage_account" "kpmgui" {
  name = "saazkpmgdevopsui${var.environmentName}"
    # allow_blob_public_access = false
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_type
  min_tls_version = "TLS1_2"
  // queue_properties  {
  //    logging {
  //        delete                = true
  //        read                  = true
  //        write                 = true
  //        version               = "1.0"
  //        retention_policy_days = 10
  //    }
// }
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    // virtual_network_subnet_ids = [azurerm_subnet.example.id]
	  bypass                     = ["Metrics", "AzureServices"]
  }
  static_website {
    index_document = "index.html"
  }
}

