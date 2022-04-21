

resource "azurerm_api_management" "example" {
  name                = "apimaz-weu-kpmg-devops-${var.environmentName}"
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher.name
  publisher_email     = var.publisher.email
  virtual_network_type = "External"

   virtual_network_configuration {
      subnet_id = var.subnet.id
      
  }

  sku_name = var.apim_sku

  # identity {
  #   type = "SystemAssigned"
  # }

  policy {
    xml_content = <<XML
        <policies>
            <inbound>
                <cors>
                    <allowed-origins>
                        <origin>*</origin>
                    </allowed-origins>
                    <allowed-methods>
                        <method>GET</method>
                        <method>OPTIONS</method>
                        <method>HEAD</method>
                        <method>DELETE</method>
                        <method>PUT</method>
                        <method>POST</method>
                        <method>PATCH</method>
                        <method>TRACE</method>
                    </allowed-methods>
                    <allowed-headers>
                        <header>content-type</header>
                        <header>Authorization</header>
                        <header>Assistant-Id</header>
                    </allowed-headers>
                </cors>
            </inbound>
            <backend>
                <forward-request />
            </backend>
            <outbound>
            </outbound>
            <on-error />
        </policies>
      XML
  }
}

resource "azurerm_api_management_logger" "example" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.example.name
  resource_group_name = var.resource_group_name
  resource_id         = var.resourceid

  application_insights {
    instrumentation_key = var.instrumentation_key
  }
}
//  resource "azurerm_key_vault_access_policy" "example" {
//    key_vault_id = var.key_vault.id

//    tenant_id = azurerm_api_management.example.identity[0].tenant_id
//    object_id = azurerm_api_management.example.identity[0].principal_id

//    secret_permissions = [
//      "get",
//    ]
//  }

data "azurerm_subscription" "current" {}

resource "azurerm_api_management_backend" "example" {
  for_each = { for function in local.functions : function => function }

  name                = replace(each.value, "", "")
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.example.name
  protocol            = "http"
  description         = replace(each.value, "", "")
  url                 = "https://${each.value}.azurewebsites.net"
  resource_id         = "https://management.azure.com/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Web/sites/${each.value}"
}

module "apiSets" {
  source              = "./submodule/apiSet"
  // project             = var.project
  environmentName     = var.environmentName
  resource_group_name = var.resource_group_name

  for_each = {
    for apiSet in local.apiSets :
    apiSet.path => apiSet
  }
  apiSet              = each.value
  api_management_name = azurerm_api_management.example.name
}



