
output "vnetwork" {
    value = azurerm_virtual_network.vnet.name      
}

output "vnetworkid" {
    value = azurerm_virtual_network.vnet.id      
}
output "subnet1" {
    value = azurerm_subnet.subnet1        
}

output "subnet" {
    value = azurerm_subnet.subnet   
}
output "subnetbe" {
    value = azurerm_subnet.subnetbe
}
output "subnetbe1" {
    value = azurerm_subnet.subnetbe1    
}
output "subnetbe2" {
    value = azurerm_subnet.subnetbe2        
}

output "publicip" {
    value = azurerm_public_ip.publicip        
}