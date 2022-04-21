

resource "azurerm_virtual_network" "vnet" {
  name                = "vnetaz-weu-kpmg-devops-${var.environmentName}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "snetaz-weu-kpmg-devops-${var.environmentName}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
  
}

resource "azurerm_subnet" "subnet1" {
  name                 = "snetaz-weu-kpmg-devops-${var.environmentName}-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.1.0/24"]

}
resource "azurerm_subnet" "subnetbe" {
  name                 = "snetaz-weu-kpmg-devops-${var.environmentName}-be"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.2.0/28"]
  
  delegation {
    name = "user-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}

resource "azurerm_subnet" "subnetbe1" {
  name                 = "snetaz-weu-kpmg-devops-${var.environmentName}-be1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.5.0/28"]
  delegation {
    name = "porkpmglio-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}

resource "azurerm_subnet" "subnetbe2" {
  name                 = "snetaz-weu-kpmg-devops-${var.environmentName}-be2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.4.0/28"]
  delegation {
    name = "auth-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}

resource "azurerm_public_ip" "publicip" {
  name                = "pip-weu-kpmg-devops-${var.environmentName}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.sku_tier == "Standard" ? "Dynamic" : "Static"
  sku                 = var.sku_tier == "Standard" ? "Basic" : "Standard"
  domain_name_label   = var.domain_name_label
}


resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-weu-kpmg-devops-${var.environmentName}-ag"
  resource_group_name  = var.resource_group_name
  location = var.location
  
}

resource "azurerm_network_security_rule" "testrules" {
  for_each                    = local.nsgrules 
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
 

  nsgrules = {
   
    appgateway = {
      name                       = "appgateway"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range    = "65200-65535"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
 
    https = {
      name                       = "http"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    }

        http = {
      name                       = "http-80"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    }
}
}