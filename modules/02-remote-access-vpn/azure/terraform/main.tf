# ------------------------------------------------------------------------------
# SDCI Lab 02 — Remote Access VPN (Azure)
# main.tf
#
# AZURE VPN GATEWAY — Point-to-Site
#
# Azure VPN Gateway provides secure site-to-site and point-to-site connectivity.
# This lab implements Point-to-Site (P2S) VPN, allowing individual remote users
# to connect to Azure resources using native VPN clients.
#
# ARCHITECTURE:
# 1. VNet with GatewaySubnet and Workload subnet
# 2. VPN Gateway (VpnGw1 SKU) in the GatewaySubnet
# 3. Self-signed root certificate for client authentication
# 4. Workload VM in the private workload subnet
#
# COST WARNING:
# Azure VPN Gateway is NOT free tier eligible. VpnGw1 SKU costs ~$0.03/hour
# (~$0.72/day). A 2-hour lab session costs ~$0.06. Always destroy after use.
#
# SDCI 300-745 CONNECTION:
# This maps to the Internet Edge layer where VPNs terminate. Remote employees
# connect via P2S VPN to access internal applications securely.
# ------------------------------------------------------------------------------

# Resource group
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# --------------------------------------------------------------------------
# VNet and subnets
# --------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_address_space]
  tags                = local.tags
}

# GatewaySubnet — must be named exactly "GatewaySubnet" for Azure to recognize it
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Workload subnet
resource "azurerm_subnet" "workload" {
  name                 = local.snet_workload
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# --------------------------------------------------------------------------
# Network Security Group for workload subnet
# Allow SSH and ICMP from VPN client address space
# --------------------------------------------------------------------------
resource "azurerm_network_security_group" "workload" {
  name                = local.nsg_workload
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "workload_allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.workload.name
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# --------------------------------------------------------------------------
# Self-signed root certificate for VPN client authentication
# --------------------------------------------------------------------------
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name         = "${local.name_prefix}-root-ca"
    organization        = "SDCI Lab"
    organizational_unit = "Training"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]

  is_ca_certificate = true
}

# --------------------------------------------------------------------------
# Public IP for VPN Gateway
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "vpn" {
  name                = local.pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = local.tags
}

# --------------------------------------------------------------------------
# VPN Gateway — VpnGw1 SKU (minimum for P2S)
# COST: ~$0.03/hour ($0.72/day if left running)
# --------------------------------------------------------------------------
resource "azurerm_virtual_network_gateway" "main" {
  name                = local.gw_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  vpn_client_configuration {
    address_space = ["172.16.0.0/24"]

    root_certificate {
      name             = "${local.name_prefix}-root-cert"
      public_cert_data = tls_self_signed_cert.root.cert_pem
    }
  }

  tags = local.tags
}

# --------------------------------------------------------------------------
# Workload VM in the workload subnet
# --------------------------------------------------------------------------
resource "azurerm_network_interface" "workload" {
  name                = "${local.workload_name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "workload" {
  name                = local.workload_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = random_password.admin.result
  disable_password_authentication = false
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.workload.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "random_password" "admin" {
  length      = 24
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}
