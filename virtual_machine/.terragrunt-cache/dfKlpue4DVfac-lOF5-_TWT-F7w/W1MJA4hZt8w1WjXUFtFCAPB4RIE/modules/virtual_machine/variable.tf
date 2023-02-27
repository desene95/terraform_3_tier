variable "location" {
  type        = string
  default     = "Canada Central"
  description = "Location where resources would be created"
}

variable "resource_group_name" {
  type        = list(string)
  description = "resource group name"
}

variable "name"{
  type = list(string)
  description = "name"
}

# variable "subnet_name"{
#   #type = string
#   description = "name of subnet"
#   default = ["web-subnet", "app-subnet", "db-subnet"]
# }
variable "address_space"{
  type = list(string)
  description = "IP address space for vnet"
  

}

variable "dbsubnetcidr"{}
variable "appsubnetcidr"{}
variable "websubnetcidr"{}
# variable "address_prefix"{
#   #type = list(string)
#   description = "prefix for subnet"
  
# }

# variable "subnet_prefix"{
#   type = list(string)
#   description = "prefix for subnet"
#   default = ["10.90.1.0/24", "10.90.2.0/24", "10.90.3.0/24"]
# }
