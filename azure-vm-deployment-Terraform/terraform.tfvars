resource_group_name = "mehul02-Learning-Azure"
use_existing_resource_group = true
vm_name             = "DevWin11Vm"
vm_start_after_creation = false
public_ip_allocation_method = "Dynamic"
location            = "West India"
admin_username      = "vmadmin"
# admin_password is provided via TF_VAR_admin_password environment variable