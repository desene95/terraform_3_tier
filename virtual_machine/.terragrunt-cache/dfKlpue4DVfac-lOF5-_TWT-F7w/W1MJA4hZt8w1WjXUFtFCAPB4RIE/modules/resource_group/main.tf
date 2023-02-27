module "naming"{
  source = "../naming"
  suffix = var.name
}
# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name 
  location = var.location

 
  tags = {
    environment = local.environment
  }
}

output "resource_group_name"{
value = azurerm_resource_group.rg.name
}

