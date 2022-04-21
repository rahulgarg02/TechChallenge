locals {
  finalEnvironmentName = var.environmentName == "" ? "" : "-${var.environmentName}"
  apiSets = [

    {
      path = "be"
      operations = [
        
      ]
      policy = <<XML
                <policies>
        <inbound>
            <base />
            <set-backend-service id="apim-generated-policy" backend-id="wapaz-weu-kpmg-devops-be-${var.environmentName}" />
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
    },

   {
      path = "be2"
      operations = [
        
      ]
      policy = <<XML
                <policies>
        <inbound>
            <base />
            <set-backend-service id="apim-generated-policy" backend-id="wapaz-weu-kpmg-devops-be2-${var.environmentName}" />
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
    },

    {
      path = "be1"
      operations = [
        
      ]
      policy = <<XML
               <policies>
        <inbound>
            <base />
            <set-backend-service id="apim-generated-policy" backend-id="wapaz-weu-kpmg-devops-be1-${var.environmentName}" />
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

  ]
}

    