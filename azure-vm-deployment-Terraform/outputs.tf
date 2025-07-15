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
  value = azurerm_public_ip.public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}