variable "subnet_name"{
  type = list(string)
  description = "name of subnet"
}
variable "address_space"{
  type = list(string)
  description = "IP address space for vnet"
}

variable "address_prefix"{
  type = list(string)
  description = "prefix for subnet"
}
