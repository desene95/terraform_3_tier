data "azurerm_client_config" "current" {}

module "naming" {
  source = "../naming"
  suffix = var.name
}

module "resource_group" {
  source = "../resource_group"
  name   = var.resource_group_name
}

resource "azurerm_virtual_network" "azvnet" {
  name                = "test-vnet"
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

# resource "azurerm_public_ip" "publicip" {
#   count               = 2
#   name                = join("-",[module.naming.public_ip.name,"${count.index}"])
#   location            = "Canada Central"
#   resource_group_name = module.resource_group.consumable
#   allocation_method   = "Static"
# }

resource "azurerm_network_interface" "webnic" {
  #count               = 2
  name                = "web-nic"
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable

  ip_configuration {
    name                 = "testconfig"
    subnet_id            = azurerm_subnet.web-subnet.id
    #public_ip_address_id = element(azurerm_public_ip.publicip.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "appnic" {
  #count               = 2
  name                = "app-nic"
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable

  ip_configuration {
    name                 = "testconfig"
    subnet_id            = azurerm_subnet.web-subnet.id
    #public_ip_address_id = element(azurerm_public_ip.publicip.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  count   = 2
  length  = 8
  special = true
}

resource "random_string" "username" {
  count            = 2
  length           = 8
  special          = false
  #override_special = "/$@"
}

resource "azurerm_key_vault" "this"{
  name = module.naming.key_vault.name
  location                   = var.location
  resource_group_name        = module.resource_group.consumable
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
    ]
    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
}
}

resource "azurerm_key_vault_secret" "username" {
  count = 2
  #for_each = resource.random_string.username
  name         = "USER-VM-SERVER-${count.index}"
  value        = random_string.username[0].result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "password" {
  count = 2
  
  #for_each = resource.random_password.password
  name         = "PASS-VM-SERVER-${count.index}"
  value        = random_password.password[0].result
  key_vault_id = azurerm_key_vault.this.id
}
##################################################################
resource "azurerm_virtual_machine" "web-vm" {
  #count                 = 2
  name                  = join("-",[module.naming.linux_virtual_machine.name,"${count.index}"])
  location              = "Canada Central"
  resource_group_name   = module.resource_group.consumable
  network_interface_ids = azurerm_network_interface.webnic.id
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = random_string.username[0].result
    admin_password = random_password.password[0].result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine" "app-vm" {
  #count                 = 2
  name                  = join("-",[module.naming.linux_virtual_machine.name,"${count.index}"])
  location              = "Canada Central"
  resource_group_name   = module.resource_group.consumable
  network_interface_ids = zurerm_network_interface.appnic.id
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = random_string.username[0].result
    admin_password = random_password.password[0].result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
