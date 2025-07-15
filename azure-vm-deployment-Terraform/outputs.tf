output "resource_group_name" {
  value = local.resource_group_name
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.win11_vm.name
}

output "vm_id" {
  value = azurerm_windows_virtual_machine.win11_vm.id
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}