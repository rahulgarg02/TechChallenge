output "connection_details" {
    value = {

        server_fqdn = azurerm_sql_server.primary.name
        username = azurerm_sql_server.primary.administrator_login
        password = azurerm_sql_server.primary.administrator_login_password
        instance_name = var.database_name
    }
}