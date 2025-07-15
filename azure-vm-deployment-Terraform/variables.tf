variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group Name"
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group or create a new one"
  default     = true
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine (used as prefix for associated resources) like DevWin11Vm_24h2pro"
  default     = "DevWin11Vm"
}

variable "vm_start_after_creation" {
  type        = bool
  description = "Whether to start the VM after creation (false = VM will be in stopped state)"
  default     = false
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
