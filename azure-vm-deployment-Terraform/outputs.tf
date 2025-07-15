output "resource_group_name" {
  value = local.resource_group_name
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.win11_vm.name
}

output "vm_id" {
  value = azurerm_windows_virtual_machine.win11_vm.id
}

output "vm_initial_state" {
  value = var.vm_start_after_creation ? "running" : "stopped (deallocated)"
  description = "Initial power state of the VM after creation"
}

output "public_ip_address" {
  value = data.azurerm_public_ip.vm_public_ip.ip_address
  description = "The actual public IP address assigned to the VM"
}

output "public_ip_address_allocation" {
  value = azurerm_public_ip.public_ip.allocation_method
  description = "The allocation method for the public IP address"
}

output "admin_username" {
  value = var.admin_username
}