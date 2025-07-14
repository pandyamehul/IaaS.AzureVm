variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "West India"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "admin_password" {
  type        = string
  description = "Password for the VM admin user"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    environment   = "devVm"
    resource_type = "devVm"
  }
}
