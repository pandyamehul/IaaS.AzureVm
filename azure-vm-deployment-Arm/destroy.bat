@echo off
setlocal enabledelayedexpansion

REM Azure VM Cleanup Script for Windows
REM This script removes only the VM and its associated resources (not the entire resource group)

echo.
echo 🗑️  Azure VM Cleanup Script
echo.

REM Configuration
set RESOURCE_GROUP_NAME=mehul02-Learning-Azure
set VM_NAME=DevWin11Vm

REM Check if Azure CLI is installed
az version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure CLI is not installed. Please install it first.
    pause
    exit /b 1
)

REM Check if user is logged in
az account show >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  You are not logged in to Azure. Please login first.
    az login
)

REM Check if resource group exists
az group show --name "%RESOURCE_GROUP_NAME%" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Resource group '%RESOURCE_GROUP_NAME%' does not exist.
    pause
    exit /b 1
)

REM Show VM-specific resources to be deleted
echo 📋 VM-specific resources to be deleted:
echo.
echo   Resource Group: %RESOURCE_GROUP_NAME%
echo   VM Name: %VM_NAME%
echo.
echo   Resources that will be deleted:
echo   - Virtual Machine: %VM_NAME%
echo   - OS Disk: %VM_NAME%-os-disk
echo   - Network Interface: %VM_NAME%-nic
echo   - Public IP: %VM_NAME%-public-ip
echo   - Network Security Group: %VM_NAME%-nsg
echo   - Virtual Network: %VM_NAME%-vnet
echo.

REM Check if VM exists
az vm show --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ VM '%VM_NAME%' does not exist in resource group '%RESOURCE_GROUP_NAME%'
    pause
    exit /b 1
)

echo ⚠️  WARNING: This will delete the VM and its associated networking resources!
echo ⚠️  Other resources in the resource group will NOT be affected.
echo.
set /p CONFIRM=Are you sure you want to continue? (yes/no): 

if not "%CONFIRM%"=="yes" (
    echo ❌ Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo 🗑️  Deleting VM and associated resources...
echo.

REM Delete VM first
echo 🖥️  Deleting Virtual Machine '%VM_NAME%'...
az vm delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%" --yes
if %errorlevel% neq 0 (
    echo ❌ Failed to delete VM
) else (
    echo ✅ VM deleted successfully
)

REM Delete OS Disk
echo 💽 Deleting OS Disk '%VM_NAME%-os-disk'...
az disk delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%-os-disk" --yes
if %errorlevel% neq 0 (
    echo ❌ Failed to delete OS Disk
) else (
    echo ✅ OS Disk deleted successfully
)

REM Delete Network Interface
echo 🔌 Deleting Network Interface '%VM_NAME%-nic'...
az network nic delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%-nic"
if %errorlevel% neq 0 (
    echo ❌ Failed to delete Network Interface
) else (
    echo ✅ Network Interface deleted successfully
)

REM Delete Public IP
echo 🌐 Deleting Public IP '%VM_NAME%-public-ip'...
az network public-ip delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%-public-ip"
if %errorlevel% neq 0 (
    echo ❌ Failed to delete Public IP
) else (
    echo ✅ Public IP deleted successfully
)

REM Delete Network Security Group
echo 🔒 Deleting Network Security Group '%VM_NAME%-nsg'...
az network nsg delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%-nsg"
if %errorlevel% neq 0 (
    echo ❌ Failed to delete Network Security Group
) else (
    echo ✅ Network Security Group deleted successfully
)

REM Delete Virtual Network
echo 🌐 Deleting Virtual Network '%VM_NAME%-vnet'...
az network vnet delete --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%-vnet"
if %errorlevel% neq 0 (
    echo ❌ Failed to delete Virtual Network
) else (
    echo ✅ Virtual Network deleted successfully
)

echo.
echo 🎉 VM cleanup completed!
echo.
echo 🔍 Checking remaining resources in resource group...
az resource list --resource-group "%RESOURCE_GROUP_NAME%" --query "[].{Name:name, Type:type}" -o table

echo.
echo � This should help reduce your Azure costs!
echo 📊 Check your Azure portal to confirm the VM resources are deleted
echo 💡 The resource group '%RESOURCE_GROUP_NAME%' still exists with any other resources
echo.

pause
