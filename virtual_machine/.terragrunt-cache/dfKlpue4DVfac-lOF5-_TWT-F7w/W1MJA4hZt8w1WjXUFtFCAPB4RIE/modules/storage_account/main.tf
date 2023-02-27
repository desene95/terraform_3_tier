module "naming" {
  source = "../naming"
  suffix = var.name
}

module "resource_group" {
  source = "../resource_group"
  name = var.resource_group_name
}

# Create Storage Account
resource "azurerm_storage_account" "example" {
  name = module.naming.storage_account.name
  resource_group_name      = module.resource_group.consumable
  location     = var.location
  account_tier  = "Standard"
  account_replication_type = "LRS"
 
  tags = {
    environment = local.environment
  }
}

