@echo off
setlocal enabledelayedexpansion

REM Azure ARM Template Deployment Script for Windows
REM This script deploys the Windows 11 VM using ARM templates

echo.
echo ^🚀 Starting Azure VM Deployment with ARM Templates
echo.

REM Configuration
set RESOURCE_GROUP_NAME=mehul02-Learning-Azure
set LOCATION=West India
set TEMPLATE_FILE=azuredeploy.json
set PARAMETERS_FILE=azuredeploy.parameters.json
set DEPLOYMENT_NAME=vm-deployment-%date:~-4,4%%date:~-7,2%%date:~-10,2%-%time:~0,2%%time:~3,2%%time:~6,2%

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

REM Prompt for admin password if not provided
if not defined ADMIN_PASSWORD (
    echo 🔒 Please enter the admin password for the VM:
    set /p ADMIN_PASSWORD=Password: 
)

REM Create resource group if it doesn't exist
echo 📦 Checking/Creating resource group: %RESOURCE_GROUP_NAME%
az group create --name "%RESOURCE_GROUP_NAME%" --location "%LOCATION%" --output none

REM Validate the template
echo ✅ Validating ARM template...
az deployment group validate ^
    --resource-group "%RESOURCE_GROUP_NAME%" ^
    --template-file "%TEMPLATE_FILE%" ^
    --parameters "%PARAMETERS_FILE%" ^
    --parameters adminPassword="%ADMIN_PASSWORD%" ^
    --output none

if %errorlevel% neq 0 (
    echo ❌ Template validation failed
    pause
    exit /b 1
)

echo ✅ Template validation successful

REM Deploy the template
echo 🚀 Deploying ARM template...
echo 📝 Deployment name: %DEPLOYMENT_NAME%

az deployment group create ^
    --resource-group "%RESOURCE_GROUP_NAME%" ^
    --name "%DEPLOYMENT_NAME%" ^
    --template-file "%TEMPLATE_FILE%" ^
    --parameters "%PARAMETERS_FILE%" ^
    --parameters adminPassword="%ADMIN_PASSWORD%" ^
    --verbose

if %errorlevel% neq 0 (
    echo ❌ Deployment failed
    pause
    exit /b 1
)

echo ✅ Deployment successful

REM Get deployment outputs
echo 📋 Getting deployment outputs...

for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query properties.outputs.vmName.value -o tsv') do set VM_NAME=%%i
for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query properties.outputs.adminUsername.value -o tsv') do set ADMIN_USERNAME=%%i
for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query properties.outputs.publicIPAddress.value -o tsv') do set PUBLIC_IP=%%i
for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query properties.outputs.publicIPAllocationMethod.value -o tsv') do set IP_METHOD=%%i
for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query properties.outputs.vmInitialState.value -o tsv') do set VM_STATE=%%i

REM Check if VM should be deallocated
echo 🔍 Checking VM power state configuration...
for /f "tokens=*" %%i in ('az deployment group show --resource-group "%RESOURCE_GROUP_NAME%" --name "%DEPLOYMENT_NAME%" --query "properties.parameters.vmStartAfterCreation.value" -o tsv') do set VM_START_AFTER_CREATION=%%i

if "%VM_START_AFTER_CREATION%"=="false" (
    echo 🛑 Deallocating VM to save costs...
    az vm deallocate --resource-group "%RESOURCE_GROUP_NAME%" --name "%VM_NAME%" --no-wait
    echo ✅ VM deallocation initiated
)

REM Display results
echo.
echo 🎉 ARM Template Deployment Complete!
echo 📋 VM Details:
echo   - VM Name: %VM_NAME%
echo   - Resource Group: %RESOURCE_GROUP_NAME%
echo   - Admin Username: %ADMIN_USERNAME%
echo   - Public IP: %PUBLIC_IP%
echo   - IP Allocation: %IP_METHOD%
echo   - VM State: %VM_STATE%
echo   - Deployment Name: %DEPLOYMENT_NAME%
echo.
echo 💰 VM is configured to be stopped after creation to save costs!

if "%IP_METHOD%"=="Dynamic" (
    echo 💡 Dynamic IP: Only charged when VM is running (~$2.40/month when active)
) else (
    echo 💡 Static IP: Always charged (~$3.65/month) but IP is reserved
)

echo.
echo 🔧 VM Management Commands:
echo   Start VM: az vm start --resource-group %RESOURCE_GROUP_NAME% --name %VM_NAME%
echo   Stop VM:  az vm deallocate --resource-group %RESOURCE_GROUP_NAME% --name %VM_NAME%
echo   Check Status: az vm show -d --resource-group %RESOURCE_GROUP_NAME% --name %VM_NAME% --query powerState
echo.
echo 🗑️  To clean up resources, run the destroy script or use GitHub Actions
echo.

pause
