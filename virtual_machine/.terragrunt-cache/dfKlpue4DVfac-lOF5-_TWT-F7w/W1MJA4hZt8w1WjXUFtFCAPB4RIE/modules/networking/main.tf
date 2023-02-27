resource "azurerm_virtual_network" "azvnet" {
  name                = "test-vnet"
  resource_group_name = module.resource_group.consumable
  address_space       = var.address_space
  location            = var.location
}

resource "azurerm_subnet" "azsubnet" {
  count                = 3
  name                 = var.subnet_name
  resource_group_name  = module.resource_group.consumable
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes       = var.address_prefix
}

# resource "azurerm_public_ip" "publicip" {
#   count               = 2
#   name                = join("-",[module.naming.public_ip.name,"${count.index}"])
#   location            = "Canada Central"
#   resource_group_name = module.resource_group.consumable
#   allocation_method   = "Static"
# }


