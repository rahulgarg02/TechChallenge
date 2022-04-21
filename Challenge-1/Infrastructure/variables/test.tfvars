# --------------------------Basic-------------------------------------------
resource_group_name = "rgaz-weu-kpmg-devops-test"

resource_group_location = "west europe"

environmentName  = "test"

tags = {
    Project = "kpmg-devops"
    Environment = "test"
}

storage_account_type = "RAGRS"

apim = {
   apim_sku = "Developer_1" 
}

apim_publisher = {
    name = "kpmgco"
    email = "r.garg@kpmg.com"
}

 function_sku1 ={
     tier = "PremiumV2"
     size = "P1v2"
 }

function_sku ={
    tier = "Standard"
    size = "S1"
}


function_kind = "Windows"

fn_location = "west europe"

fehost = "mytest.kpmgco.dev"
