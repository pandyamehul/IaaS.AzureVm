#!/bin/bash

# Azure ARM Template Deployment Script
# This script deploys the Windows 11 VM using ARM templates

set -e

# Configuration
RESOURCE_GROUP_NAME="mehul02-Learning-Azure"
LOCATION="West India"
TEMPLATE_FILE="azuredeploy.json"
PARAMETERS_FILE="azuredeploy.parameters.json"
DEPLOYMENT_NAME="vm-deployment-$(date +%Y%m%d%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Azure VM Deployment with ARM Templates${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  You are not logged in to Azure. Please login first.${NC}"
    az login
fi

# Prompt for admin password if not provided
if [ -z "$ADMIN_PASSWORD" ]; then
    echo -e "${YELLOW}🔒 Please enter the admin password for the VM:${NC}"
    read -s ADMIN_PASSWORD
    echo
fi

# Create resource group if it doesn't exist
echo -e "${BLUE}📦 Checking/Creating resource group: $RESOURCE_GROUP_NAME${NC}"
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output none

# Validate the template
echo -e "${BLUE}✅ Validating ARM template...${NC}"
az deployment group validate \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "$PARAMETERS_FILE" \
    --parameters adminPassword="$ADMIN_PASSWORD" \
    --output none

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Template validation successful${NC}"
else
    echo -e "${RED}❌ Template validation failed${NC}"
    exit 1
fi

# Deploy the template
echo -e "${BLUE}🚀 Deploying ARM template...${NC}"
echo -e "${YELLOW}📝 Deployment name: $DEPLOYMENT_NAME${NC}"

az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "$PARAMETERS_FILE" \
    --parameters adminPassword="$ADMIN_PASSWORD" \
    --verbose

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment successful${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Get deployment outputs
echo -e "${BLUE}📋 Getting deployment outputs...${NC}"

VM_NAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs.vmName.value -o tsv)

ADMIN_USERNAME=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs.adminUsername.value -o tsv)

PUBLIC_IP=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs.publicIPAddress.value -o tsv)

IP_METHOD=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs.publicIPAllocationMethod.value -o tsv)

VM_STATE=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query properties.outputs.vmInitialState.value -o tsv)

# Check if VM should be deallocated
echo -e "${BLUE}🔍 Checking VM power state configuration...${NC}"
VM_START_AFTER_CREATION=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --query "properties.parameters.vmStartAfterCreation.value" -o tsv)

if [ "$VM_START_AFTER_CREATION" = "false" ]; then
    echo -e "${YELLOW}🛑 Deallocating VM to save costs...${NC}"
    az vm deallocate --resource-group "$RESOURCE_GROUP_NAME" --name "$VM_NAME" --no-wait
    echo -e "${GREEN}✅ VM deallocation initiated${NC}"
fi

# Display results
echo -e "${GREEN}🎉 ARM Template Deployment Complete!${NC}"
echo -e "${BLUE}📋 VM Details:${NC}"
echo -e "  - VM Name: ${GREEN}$VM_NAME${NC}"
echo -e "  - Resource Group: ${GREEN}$RESOURCE_GROUP_NAME${NC}"
echo -e "  - Admin Username: ${GREEN}$ADMIN_USERNAME${NC}"
echo -e "  - Public IP: ${GREEN}$PUBLIC_IP${NC}"
echo -e "  - IP Allocation: ${GREEN}$IP_METHOD${NC}"
echo -e "  - VM State: ${GREEN}$VM_STATE${NC}"
echo -e "  - Deployment Name: ${GREEN}$DEPLOYMENT_NAME${NC}"
echo ""
echo -e "${YELLOW}💰 VM is configured to be stopped after creation to save costs!${NC}"

if [ "$IP_METHOD" = "Dynamic" ]; then
    echo -e "${BLUE}💡 Dynamic IP: Only charged when VM is running (~$2.40/month when active)${NC}"
else
    echo -e "${BLUE}💡 Static IP: Always charged (~$3.65/month) but IP is reserved${NC}"
fi

echo ""
echo -e "${BLUE}🔧 VM Management Commands:${NC}"
echo -e "  Start VM: ${GREEN}az vm start --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME${NC}"
echo -e "  Stop VM:  ${GREEN}az vm deallocate --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME${NC}"
echo -e "  Check Status: ${GREEN}az vm show -d --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query powerState${NC}"
echo ""
echo -e "${YELLOW}🗑️  To clean up resources, run the destroy script or use GitHub Actions${NC}"
