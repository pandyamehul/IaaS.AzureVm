@echo off
echo 🔍 Checking Azure Resources...
echo.

REM Check if Azure CLI is installed
az version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure CLI is not installed
    pause
    exit /b 1
)

REM Check if logged in
az account show >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Please login to Azure first
    az login
)

echo 📋 Resources in resource group 'mehul02-Learning-Azure':
az resource list --resource-group "mehul02-Learning-Azure" --query "[].{Name:name, Type:type, Location:location}" -o table

echo.
echo 🔍 Checking for specific VM 'DevWin11Vm':
az vm show --resource-group "mehul02-Learning-Azure" --name "DevWin11Vm" --query "{Name:name, PowerState:powerState, Location:location}" -o table 2>nul

if %errorlevel% neq 0 (
    echo ❌ VM 'DevWin11Vm' not found
) else (
    echo ✅ VM 'DevWin11Vm' exists
)

echo.
echo 💰 Estimated monthly costs:
echo VM Standard_B2ms: ~$60-80/month when running
echo Dynamic Public IP: ~$2.40/month when VM running
echo Storage: ~$5-10/month
echo Network: ~$1-2/month
echo Total when running: ~$68-95/month
echo Total when stopped: ~$6-12/month

pause
