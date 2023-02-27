variable "virtual_network_name" {
  
}

variable "resource_group_name" {
    type = list(string)
  
}

variable "address_space" {
  
}

variable "location" {
    default = "Canada Central"
  
}
# output "consumable" {
#   value       = local.consumable
#   description = "The consumable object. It is the responsibility of the consumable to conceal sensitive attributes."
#   sensitive   = false
# }

variable "websubnetcidr"{}
variable "appsubnetcidr"{}
variable "dbsubnetcidr"{}