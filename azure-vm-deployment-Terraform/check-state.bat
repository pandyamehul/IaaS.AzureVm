@echo off
echo 🔍 Checking Terraform State...
echo.

cd /d "%~dp0"

echo 📋 Current directory contents:
dir /b

echo.
echo 🔧 Initializing Terraform...
terraform init

echo.
echo 📊 Checking Terraform state:
terraform state list

echo.
echo 🗺️ Showing current state:
terraform show

echo.
echo 📋 Planning to see what would be created:
terraform plan -var-file="terraform.tfvars"

pause
