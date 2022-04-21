
module "mssql" {
  for_each = {
    for mssqlConfig in local.mssqlConfigs :
    mssqlConfig.database_name => mssqlConfig
  }
  source              = "./submodule"
  environmentName     = var.environmentName
  resource_group_name = var.resource_group_name
  location            = var.location

  database_name       = each.value.database_name
  enable_threat_detection_policy    = true
 
  password_policy            = var.password_policy
  log_analytics_workspace_id = var.log_analytics_workspace_id
  vnet                       = var.vnet


}
