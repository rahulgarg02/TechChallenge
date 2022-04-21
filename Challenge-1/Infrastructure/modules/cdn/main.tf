
resource "azurerm_cdn_profile" "kpmgco" {
  name                = "cdnaz-weu-kpmg-devops-${var.environmentName}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"
}
