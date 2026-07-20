# ------------------------------------------------------------------------------
# SDCI Lab 01 — VNet Segmentation (Azure)
# main.tf
#
# THREE-TIER VNET DESIGN
#
# Azure VNets contain subnets with NSG and route table associations.
# We map the Cisco three-tier model as follows:
#   Access subnet      (10.0.1.0/24) = Access Layer
#   Distribution subnet (10.0.2.0/24) = Distribution Layer
#   Core subnet         (10.0.3.0/24) = Core Layer
#
# DECISION: NSGs vs. Azure Firewall
# Azure Firewall costs ~$1.50/day and requires a dedicated subnet.
# NSGs are free, stateful, and sufficient for Module 01.
# Azure Firewall is introduced in Module 03 (NGFW).
# ------------------------------------------------------------------------------

# Resource group — all resources for this module live here
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# Random password for bastion if not provided
resource "random_password" "admin" {
  length      = 24
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

# --------------------------------------------------------------------------
# VNet and subnets
# --------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.ip_ranges.vnet]
  tags                = local.tags
}

# Access subnet — end-user connectivity, bastion host
resource "azurerm_subnet" "access" {
  name                 = "snet-access"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges.access]
}

# Distribution subnet — policy enforcement boundary
resource "azurerm_subnet" "distribution" {
  name                 = "snet-distribution"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges.distribution]
}

# Core subnet — backend services, NAT Gateway
resource "azurerm_subnet" "core" {
  name                 = "snet-core"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.ip_ranges.core]
}

# --------------------------------------------------------------------------
# Network Security Groups (stateful, free tier)
# --------------------------------------------------------------------------
resource "azurerm_network_security_group" "access" {
  name                = local.nsg_access
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "access_allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = ["*"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.access.name
}

resource "azurerm_network_security_rule" "access_deny_all" {
  name                        = "Deny-All-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.access.name
}

resource "azurerm_subnet_network_security_group_association" "access" {
  subnet_id                 = azurerm_subnet.access.id
  network_security_group_id = azurerm_network_security_group.access.id
}

# Distribution NSG — allows SSH only from Access subnet, blocks access→core
resource "azurerm_network_security_group" "distribution" {
  name                = local.nsg_distribution
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "dist_allow_ssh_from_access" {
  name                        = "Allow-SSH-From-Access"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = [var.ip_ranges.access]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.distribution.name
}

resource "azurerm_network_security_rule" "dist_deny_access_to_core" {
  name                        = "Deny-Access-To-Core"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefixes = [var.ip_ranges.core]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.distribution.name
}

resource "azurerm_subnet_network_security_group_association" "distribution" {
  subnet_id                 = azurerm_subnet.distribution.id
  network_security_group_id = azurerm_network_security_group.distribution.id
}

# Core NSG — allows SSH from Distribution only (lateral movement prevention)
resource "azurerm_network_security_group" "core" {
  name                = local.nsg_core
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "core_allow_ssh_from_dist" {
  name                        = "Allow-SSH-From-Distribution"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = [var.ip_ranges.distribution]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.core.name
}

resource "azurerm_subnet_network_security_group_association" "core" {
  subnet_id                 = azurerm_subnet.core.id
  network_security_group_id = azurerm_network_security_group.core.id
}

# --------------------------------------------------------------------------
# NAT Gateway for private subnet egress (paid resource)
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat ? 1 : 0
  name                = local.nat_pip
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = local.tags
}

resource "azurerm_nat_gateway" "main" {
  count               = var.enable_nat ? 1 : 0
  name                = local.nat_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"
  zones               = ["1"]
  tags                = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  count                = var.enable_nat ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.main[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "distribution" {
  count          = var.enable_nat ? 1 : 0
  subnet_id      = azurerm_subnet.distribution.id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}

resource "azurerm_subnet_nat_gateway_association" "core" {
  count          = var.enable_nat ? 1 : 0
  subnet_id      = azurerm_subnet.core.id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}

# --------------------------------------------------------------------------
# Bastion host — minimal B1s VM in access subnet
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.bastion_pip
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.bastion_nic
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig-bastion"
    subnet_id                     = azurerm_subnet.access.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = local.bastion_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  disable_password_authentication = false
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.bastion[0].id]

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

  custom_data = base64encode(<<-EOF
    #cloud-config
    runcmd:
      - echo "SDCI Lab 01 — Bastion Host deployed" > /etc/motd
  EOF
  )
}
