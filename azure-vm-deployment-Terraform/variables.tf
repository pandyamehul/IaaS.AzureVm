variable "resource_group_name" {
  type        = string
  description = "mehul02-Learning-Azure"
}

variable "location" {
  type        = string
  default     = "West India"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "vmadmin"
}

variable "admin_password" {
  type        = string
  description = ""
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
