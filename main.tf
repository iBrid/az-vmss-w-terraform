# Resource Group
resource "azurerm_resource_group" "vmss" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "vmss" {
  name                = "${var.vmss_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  tags                = var.tags
}

# Subnet
resource "azurerm_subnet" "vmss" {
  name                 = "${var.vmss_name}-subnet"
  resource_group_name  = azurerm_resource_group.vmss.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = var.subnet_address_prefixes
}

# Network Security Group
# Note: These rules allow HTTP/HTTPS from any source for flexibility.
# For production, consider restricting source_address_prefix to specific IP ranges.
resource "azurerm_network_security_group" "vmss" {
  name                = "${var.vmss_name}-nsg"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "vmss" {
  subnet_id                 = azurerm_subnet.vmss.id
  network_security_group_id = azurerm_network_security_group.vmss.id
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "vmss" {
  name                = "${var.vmss_name}-pip"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Load Balancer
resource "azurerm_lb" "vmss" {
  name                = "${var.vmss_name}-lb"
  location            = azurerm_resource_group.vmss.location
  resource_group_name = azurerm_resource_group.vmss.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "vmss" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "${var.vmss_name}-backend-pool"
}

# Health Probe
resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "${var.vmss_name}-health-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "vmss" {
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "${var.vmss_name}-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss.id]
  probe_id                       = azurerm_lb_probe.vmss.id
}

# Virtual Machine Scale Set
# Note: Password authentication is enabled for flexibility. For production,
# consider using SSH key authentication by setting disable_password_authentication = true
# and adding an admin_ssh_key block.
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = var.vmss_name
  resource_group_name             = azurerm_resource_group.vmss.name
  location                        = azurerm_resource_group.vmss.location
  sku                             = var.vm_sku
  instances                       = var.instance_count
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  tags                            = var.tags

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss.id]
    }
  }
}
