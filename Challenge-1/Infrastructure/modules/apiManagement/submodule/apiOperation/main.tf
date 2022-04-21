resource "azurerm_api_management_api_operation" "example" {
  api_name            = var.api_name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name

  operation_id = var.operation.display_name
  display_name = var.operation.display_name
  method       = var.operation.method
  url_template = var.operation.url_template

  response {
    status_code = 200
  }

  dynamic "template_parameter" {
    for_each = {
      for parameter in lookup(var.operation, "template_parameters", [])
      : parameter => parameter
    }
    content {
      name     = template_parameter.key
      required = true
      type     = "string"
    }
  }

  request {
    dynamic "query_parameter" {
      for_each = {
        for parameter in lookup(var.operation, "query_parameters", [])
        : parameter => parameter
      }
      content {
        name     = template_parameter.key
        required = true
        type     = "string"
      }
    }
  }


}

locals {
  defaultPolicy = <<XML
    <policies>
        <inbound>
            <base />
            <set-backend-service id="apim-generated-policy" backend-id="wapaz-weu-kpmg-devops-${var.operation.function}-${var.environmentName}" />
        </inbound>
        <backend>
            <base />
        </backend>
        <outbound>
            <base />
        </outbound>
        <on-error>
            <base />
        </on-error>
    </policies>
  XML
}

resource "azurerm_api_management_api_operation_policy" "example" {
  api_name            = var.api_name
  api_management_name = var.api_management_name
  resource_group_name = var.resource_group_name
  operation_id        = azurerm_api_management_api_operation.example.operation_id
  xml_content         = lookup(var.operation, "policy", local.defaultPolicy)

}
