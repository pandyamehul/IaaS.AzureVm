variable "resource_group_name" {
  type        = string
  description = "mehul02-Learning-Azure"
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group or create a new one"
  default     = true
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
    environment   = "Development"
    resource_type = "devVm"
  }
}
