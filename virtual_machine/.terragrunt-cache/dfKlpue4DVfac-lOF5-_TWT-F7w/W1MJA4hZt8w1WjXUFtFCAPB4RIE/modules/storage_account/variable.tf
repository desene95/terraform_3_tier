variable "location" {
  type        = string
  default     = "Canada Central"
  description = "default resources location"
}
variable "name" {
  type        = list(string)
  description = "storage account name"
}
variable "resource_group_name" {
  type        = list(string)
  description = "resource group name"
}

