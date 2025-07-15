# Azure ARM Templates for Windows 11 VM Deployment

This folder contains Azure Resource Manager (ARM) templates for deploying a Windows 11 virtual machine with associated networking resources.

## 📁 Files Structure

    ```
    azure-vm-deployment-Arm/
    ├── azuredeploy.json              # Main ARM template
    ├── azuredeploy.parameters.json   # Parameters file
    ├── vm-deallocate.json            # VM power state helper template
    └── README.md                     # This file
    ```

## 🎯 Templates Overview

### 1. **azuredeploy.json** - Main Template

Creates the following resources:

- **Virtual Network** (`{vmName}-vnet`) with subnet (`{vmName}-subnet`)
- **Public IP Address** (`{vmName}-public-ip`) - Dynamic or Static
- **Network Security Group** (`{vmName}-nsg`) with RDP rule
- **Network Interface** (`{vmName}-nic`) 
- **Windows 11 Virtual Machine** (`{vmName}`)

### 2. **azuredeploy.parameters.json** - Parameters

Default configuration values:

- VM Name: `DevWin11Vm`
- Admin Username: `vmadmin`
- VM Size: `Standard_B2ms`
- Location: `West India`
- IP Allocation: `Dynamic`
- Start After Creation: `false`

### 3. **vm-deallocate.json** - Power State Helper

Provides VM power state information and deallocate commands.

## 🚀 Deployment Methods

### Method 1: GitHub Actions (Recommended)

Use the workflow file: `.github/workflows/deploy-arm.yml`

1. Go to **Actions** tab in GitHub
2. Select **Deploy Windows 11 VM (via ARM Templates)**
3. Click **Run workflow**
4. Choose **deploy** action
5. Click **Run workflow**

### Method 2: Azure CLI

    ```bash
    # Login to Azure
    az login

    # Create resource group (if not exists)
    az group create --name mehul02-Learning-Azure --location "West India"

    # Deploy template
    az deployment group create \
    --resource-group mehul02-Learning-Azure \
    --template-file azuredeploy.json \
    --parameters azuredeploy.parameters.json \
    --parameters adminPassword="YourSecurePassword123!"
    ```

### Method 3: Azure Portal

1. Upload `azuredeploy.json` to Azure Portal
2. Fill in parameters
3. Deploy

## 🔧 Configuration Options

### VM Sizes

- `Standard_B1s` - 1 vCPU, 1 GB RAM (Basic)
- `Standard_B2s` - 2 vCPU, 4 GB RAM (Standard)
- `Standard_B2ms` - 2 vCPU, 8 GB RAM (Recommended)
- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM (Performance)
- `Standard_D4s_v3` - 4 vCPU, 16 GB RAM (High Performance)

### IP Allocation Methods

- **Dynamic**: Lower cost (~$2.40/month when running)
- **Static**: Higher cost (~$3.65/month always) but reserved IP

### Auto-Stop Configuration

- `vmStartAfterCreation: false` - VM stops after creation (cost-saving)
- `vmStartAfterCreation: true` - VM remains running

## 📊 Cost Optimization

### VM Stopped (Deallocated)

- **Compute**: $0 (not charged)
- **Storage**: ~$4-8/month (OS disk)
- **Network**: Dynamic IP: $0, Static IP: ~$3.65/month

### VM Running

- **Compute**: ~$35-70/month (depends on size)
- **Storage**: ~$4-8/month (OS disk)
- **Network**: Dynamic/Static IP: ~$2.40-3.65/month

## 🔄 VM Management Commands

### Start VM

    ```bash
    az vm start --resource-group mehul02-Learning-Azure --name DevWin11Vm
    ```

### Stop VM (Deallocate)

    ```bash
    az vm deallocate --resource-group mehul02-Learning-Azure --name DevWin11Vm
    ```

### Check VM Status

    ```bash
    az vm show --resource-group mehul02-Learning-Azure --name DevWin11Vm --show-details --query powerState
    ```

### Get Public IP

    ```bash
    az vm show -d --resource-group mehul02-Learning-Azure --name DevWin11Vm --query publicIps -o tsv
    ```

## 🗑️ Cleanup

### Option 1: Use GitHub Actions

1. Go to **Actions** tab
2. Select **Deploy Windows 11 VM (via ARM Templates)**
3. Click **Run workflow**
4. Choose **destroy** action
5. Type **DESTROY** in confirmation
6. Click **Run workflow**

### Option 2: Azure CLI (Specific Resources Only)

    ```bash
    # Delete VM and associated resources (in proper order)
    az vm delete --resource-group mehul02-Learning-Azure --name DevWin11Vm --yes
    az network nic delete --resource-group mehul02-Learning-Azure --name DevWin11Vm-nic --yes
    az network public-ip delete --resource-group mehul02-Learning-Azure --name DevWin11Vm-public-ip --yes
    az network nsg delete --resource-group mehul02-Learning-Azure --name DevWin11Vm-nsg --yes
    az network vnet delete --resource-group mehul02-Learning-Azure --name DevWin11Vm-vnet --yes
    ```

### Option 3: Complete Resource Group Deletion (⚠️ WARNING)

    ```bash
    # Only use this if you want to delete ALL resources in the resource group
    az group delete --name mehul02-Learning-Azure --yes
    ```

## 🔒 Security Notes

1. **RDP Access**: Currently allows RDP from any IP (`*`)
2. **Admin Password**: Stored as GitHub secret
3. **Network Security**: Basic NSG with RDP rule only

## 📋 Outputs

The template provides these outputs:

- `vmName` - Name of the created VM
- `resourceGroupName` - Resource group name
- `adminUsername` - Admin username
- `publicIPAddress` - Public IP address
- `publicIPAllocationMethod` - IP allocation method
- `vmInitialState` - VM power state
- `vmId` - VM resource ID

## 🆚 ARM vs Terraform Comparison

| Feature | ARM Templates | Terraform |
|---------|---------------|-----------|
| **Language** | JSON | HCL |
| **State Management** | Azure handles | Terraform state file |
| **Learning Curve** | Steeper | Easier |
| **Azure Integration** | Native | Third-party provider |
| **Multi-Cloud** | Azure only | Multi-cloud support |
| **Debugging** | More complex | Better error messages |

## 📚 Learning Resources

- [ARM Template Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
- [ARM Template Best Practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/best-practices)
- [ARM Template Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions)

## 🤝 Contributing

Feel free to modify the templates for your specific needs:

1. Update `azuredeploy.parameters.json` for different configurations
2. Modify `azuredeploy.json` for additional resources
3. Adjust GitHub Actions workflow for custom deployment logic
