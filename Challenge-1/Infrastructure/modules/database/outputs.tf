output "connection_details" {
    value = {
        for dbInstance in module.mssql:
        dbInstance.connection_details.instance_name => dbInstance.connection_details
    }
}