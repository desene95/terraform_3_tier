data "azurerm_client_config" "current" {}

module "naming" {
  source = "../naming"
  suffix = var.name
}

module "resource_group" {
  source = "../resource_group"
  name   = var.resource_group_name
}

module "virtual_network" {
  source = "../virtual_network"
  virtual_network_name = var.virtual_network_name
  resource_group_name = var.resource_group_name
  address_space = var.address_space
  websubnetcidr = var.websubnetcidr
  appsubnetcidr = var.appsubnetcidr
  dbsubnetcidr = var.dbsubnetcidr
}

resource "azurerm_public_ip" "webip" {
  name                = join("-",[module.naming.public_ip.name,"${var.web_host_name}"])
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "appip" {
  name                = join("-",[module.naming.public_ip.name,"${var.app_host_name}"])
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "webnic" {
  #count               = 2
  name                = var.web_nic
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable

  ip_configuration {
    name                 = "testconfig-0"
    subnet_id            = module.virtual_network.web-subnet
    public_ip_address_id = azurerm_public_ip.webip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "appnic" {
  #count               = 2
  name                = var.app_nic
  location            = "Canada Central"
  resource_group_name = module.resource_group.consumable

  ip_configuration {
    name                 = "testconfig-1"
    subnet_id            = module.virtual_network.app-subnet
    public_ip_address_id = azurerm_public_ip.appip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  count   = 2
  length  = 15
  special = false
  upper =  true
}

resource "random_string" "username" {
  count            = 2
  length           = 15
  special          = false
  upper = false
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

resource "azurerm_key_vault_secret" "web-username" {
  name         = "admin-user-${var.web_host_name}"
  value        = random_string.username[0].result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "app-username" {
  name         = "admin-user-${var.app_host_name}"
  value        = random_string.username[1].result
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_key_vault_secret" "web-password" {
  name         = "admin-pwd-${var.web_host_name}"
  value         = random_password.password[0].result
  key_vault_id = azurerm_key_vault.this.id
  #provider = azurerm.kvsub

}

resource "azurerm_key_vault_secret" "app-password" {
  #count = 2
  
  #for_each = resource.random_password.password
  name         = "admin-pwd-${var.app_host_name}"
  #value        = random_password.password[0].result
  value         = random_password.password[1].result
  key_vault_id = azurerm_key_vault.this.id
  #provider = azurerm.kvsub

}


##################################################################
resource "azurerm_virtual_machine" "web-vm" {
  #count                 = 2
  name                  = "web-vm"
  location              = "Canada Central"
  resource_group_name   = module.resource_group.consumable
  network_interface_ids = [azurerm_network_interface.webnic.id]
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
    name              = "myosdisk-web"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.web_host_name
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
  name                  = "app-vm"
  location              = "Canada Central"
  resource_group_name   = module.resource_group.consumable
  network_interface_ids = [azurerm_network_interface.appnic.id]
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
    name              = "myosdisk-app"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.app_host_name
    admin_username = random_string.username[1].result
    admin_password = random_password.password[1].result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
