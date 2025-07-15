@echo off
setlocal enabledelayedexpansion

REM Azure ARM Template Cleanup Script for Windows
REM This script removes all resources created by the ARM template

echo.
echo 🗑️  Azure VM Cleanup Script
echo.

REM Configuration
set RESOURCE_GROUP_NAME=mehul02-Learning-Azure

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

REM Show resources in the group
echo 📋 Resources in resource group '%RESOURCE_GROUP_NAME%':
az resource list --resource-group "%RESOURCE_GROUP_NAME%" --query "[].{Name:name, Type:type, Location:location}" -o table

echo.
echo ⚠️  WARNING: This will DELETE ALL resources in the resource group!
echo 🗑️  Resource Group: %RESOURCE_GROUP_NAME%
echo.
set /p CONFIRM=Are you sure you want to continue? (yes/no): 

if not "%CONFIRM%"=="yes" (
    echo ❌ Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo 🗑️  Deleting resource group '%RESOURCE_GROUP_NAME%'...
echo ⏳ This may take several minutes...

az group delete --name "%RESOURCE_GROUP_NAME%" --yes --no-wait

if %errorlevel% neq 0 (
    echo ❌ Failed to initiate resource group deletion
    pause
    exit /b 1
)

echo.
echo ✅ Resource group deletion initiated!
echo 📝 Note: Deletion is running in the background and may take 5-10 minutes to complete.
echo.
echo 🔍 To check deletion status, run:
echo    az group show --name "%RESOURCE_GROUP_NAME%" --query properties.provisioningState -o tsv
echo.
echo 💡 When complete, the command above will return an error (group not found).
echo.

pause
