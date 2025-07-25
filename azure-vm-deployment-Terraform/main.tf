provider "azurerm" {
  features {}
}

# Try to use existing resource group, create if it doesn't exist
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
  count = var.use_existing_resource_group ? 1 : 0
}

resource "azurerm_resource_group" "rg" {
  count    = var.use_existing_resource_group ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.use_existing_resource_group ? data.azurerm_resource_group.existing_rg[0].name : azurerm_resource_group.rg[0].name
  location = var.use_existing_resource_group ? data.azurerm_resource_group.existing_rg[0].location : azurerm_resource_group.rg[0].location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-public-ip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_allocation_method == "Static" ? "Standard" : "Basic"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "win11_vm" {
  name                = var.vm_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-avd"
    version   = "latest"
  }

  enable_automatic_updates = true
  tags = var.tags
}

# VM shutdown resource to control initial state
resource "null_resource" "vm_state_control" {
  depends_on = [azurerm_windows_virtual_machine.win11_vm]

  provisioner "local-exec" {
    command = var.vm_start_after_creation ? "echo 'VM will remain in running state'" : "az vm deallocate --resource-group ${local.resource_group_name} --name ${var.vm_name}"
  }

  # Re-run if vm_start_after_creation changes
  triggers = {
    vm_start_after_creation = var.vm_start_after_creation
    vm_name = var.vm_name
  }
}

# Data source to get the actual public IP address
data "azurerm_public_ip" "vm_public_ip" {
  depends_on          = [azurerm_windows_virtual_machine.win11_vm]
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = local.resource_group_name
}
