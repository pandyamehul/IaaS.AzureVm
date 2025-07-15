@echo off
echo 🔄 Importing existing Azure resources to Terraform state...
echo.

cd /d "%~dp0"

REM Initialize Terraform first
echo 🔧 Initializing Terraform...
terraform init

echo.
echo 🔍 Checking current state:
terraform state list

echo.
echo 📥 Attempting to import existing resources...
echo Note: This will only work if the resources exist in Azure

REM Import resource group (if it exists)
echo Importing resource group...
terraform import azurerm_resource_group.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure

REM Import virtual network (if it exists)
echo Importing virtual network...
terraform import azurerm_virtual_network.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Network/virtualNetworks/DevWin11Vm-vnet

REM Import subnet (if it exists)
echo Importing subnet...
terraform import azurerm_subnet.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Network/virtualNetworks/DevWin11Vm-vnet/subnets/DevWin11Vm-subnet

REM Import public IP (if it exists)
echo Importing public IP...
terraform import azurerm_public_ip.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Network/publicIPAddresses/DevWin11Vm-ip

REM Import network security group (if it exists)
echo Importing network security group...
terraform import azurerm_network_security_group.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Network/networkSecurityGroups/DevWin11Vm-nsg

REM Import network interface (if it exists)
echo Importing network interface...
terraform import azurerm_network_interface.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Network/networkInterfaces/DevWin11Vm-nic

REM Import virtual machine (if it exists)
echo Importing virtual machine...
terraform import azurerm_windows_virtual_machine.main /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/mehul02-Learning-Azure/providers/Microsoft.Compute/virtualMachines/DevWin11Vm

echo.
echo 📊 Final state after import:
terraform state list

echo.
echo 🗺️ Planning to see current state:
terraform plan -var-file="terraform.tfvars"

pause
