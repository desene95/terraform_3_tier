module "resource_group" {
  source = "../resource_group"
  name   = var.resource_group_name
}

resource "azurerm_virtual_network" "azvnet" {
  name                = var.virtual_network_name
  resource_group_name = module.resource_group.consumable
  address_space       = var.address_space
  location            = var.location
}

resource "azurerm_subnet" "web-subnet" {
  name                 =  "web-subnet"
  resource_group_name  = module.resource_group.consumable
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes       = var.websubnetcidr
}

resource "azurerm_subnet" "app-subnet" {
  name                 =  "app-subnet"
  resource_group_name  = module.resource_group.consumable
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes       = var.appsubnetcidr
}

resource "azurerm_subnet" "db-subnet" {
  name                 =  "db-subnet"
  resource_group_name  = module.resource_group.consumable
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes       = var.dbsubnetcidr
}

output "db-subnet"{
value = azurerm_subnet.db-subnet.id
}

output "app-subnet"{
value = azurerm_subnet.app-subnet.id
}

output "web-subnet"{
value = azurerm_subnet.app-subnet.id
}

output "vnet_name"{
value = azurerm_virtual_network.azvnet.name
}