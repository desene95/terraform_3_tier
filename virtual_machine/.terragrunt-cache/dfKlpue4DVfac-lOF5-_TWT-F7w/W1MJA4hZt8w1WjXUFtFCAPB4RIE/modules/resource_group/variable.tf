variable "location" {
  type        = string
  default     = "Canada Central"
  description = "default resources location"
}
 
variable "name" {
  type        = list(string)
  description = "resource group name"
}

output "consumable" {
  value       = local.consumable
  description = "The consumable object. It is the responsibility of the consumable to conceal sensitive attributes."
  sensitive   = false
}
