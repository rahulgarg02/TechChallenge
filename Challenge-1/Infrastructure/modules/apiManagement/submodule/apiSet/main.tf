resource "azurerm_api_management_api_version_set" "example" {
  name                = var.apiSet.path
  display_name        = "${var.apiSet.path}-${var.environmentName}"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  versioning_scheme   = "Segment"
}

resource "azurerm_api_management_api" "example" {
  name                = azurerm_api_management_api_version_set.example.name
  resource_group_name = azurerm_api_management_api_version_set.example.resource_group_name
  api_management_name = azurerm_api_management_api_version_set.example.api_management_name
  revision            = "1"
  display_name        = azurerm_api_management_api_version_set.example.name
  path                = azurerm_api_management_api_version_set.example.name
  protocols           = ["https"]

  subscription_required = false

  // version        = "v1"
  // version_set_id = azurerm_api_management_api_version_set.example.id
}

resource "azurerm_api_management_api_policy" "example" {
  depends_on = [azurerm_api_management_api.example]

  api_name            = azurerm_api_management_api.example.name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name

  xml_content = var.apiSet.policy
}

module "apiOperation" {
  depends_on = [azurerm_api_management_api.example]

  source = "./../apiOperation"
  for_each = { for operation in var.apiSet.operations :
    operation.display_name => operation
  }
  operation = each.value

  api_name            = azurerm_api_management_api.example.name
  api_management_name = azurerm_api_management_api.example.api_management_name

  // project             = var.project
  resource_group_name = var.resource_group_name
  environmentName     = var.environmentName
}
