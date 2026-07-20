# ------------------------------------------------------------------------------
# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (Azure)
# main.tf
#
# Three security layers:
#   1. Azure Front Door + WAF Policy — Layer 7 web application firewall
#   2. NSGs + Application Security Groups — Zone-based segmentation
#   3. Defender for Cloud — Threat detection
#
# ARCHITECTURE:
#   Internet → Front Door (WAF) → VM Web (NSG enforced) → VM App (NSG enforced)
#                                 ↓
#                          Defender for Cloud
#
# COST: Front Door ~$0.89/day, VM (B1s) ~$0.14/day, NSGs/WAF policy free.
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Resource group
# --------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# --------------------------------------------------------------------------
# Virtual network and subnets
# --------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "web" {
  name                 = local.snet_web
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = local.snet_app
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# --------------------------------------------------------------------------
# APPLICATION SECURITY GROUPS — Logical zone grouping
# --------------------------------------------------------------------------
resource "azurerm_application_security_group" "web" {
  name                = local.asg_web
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_application_security_group" "app" {
  name                = local.asg_app
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# --------------------------------------------------------------------------
# NETWORK SECURITY GROUPS — Zone-based stateful firewall
# --------------------------------------------------------------------------
resource "azurerm_network_security_group" "web" {
  name                = local.nsg_web
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "web_allow_http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefixes     = ["10.0.0.0/16"]
  destination_application_security_group_ids = [azurerm_application_security_group.web.id]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "web_allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = ["0.0.0.0/0"]
  destination_application_security_group_ids = [azurerm_application_security_group.web.id]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_rule" "web_deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["*"]
  destination_application_security_group_ids = [azurerm_application_security_group.web.id]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_network_security_group" "app" {
  name                = local.nsg_app
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "app_allow_http_from_web" {
  name                        = "AllowHTTPFromWeb"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_application_security_group_ids = [azurerm_application_security_group.web.id]
  destination_application_security_group_ids = [azurerm_application_security_group.app.id]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_rule" "app_deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["*"]
  destination_application_security_group_ids = [azurerm_application_security_group.app.id]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}

# Associate NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# --------------------------------------------------------------------------
# VM — Web tier
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "web" {
  name                = local.pip_web
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "web" {
  name                          = local.nic_web
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  enable_accelerated_networking = false
  tags                          = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                            = local.vm_web
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_B1s"
  admin_username                  = "sdciadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.web.id]
  tags                            = local.tags

  admin_ssh_key {
    username   = "sdciadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<html><body><h1>SDCI Lab 03 — Protected by Azure WAF</h1><p>Instance: $(hostname)</p></body></html>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
}

# --------------------------------------------------------------------------
# AZURE FRONT DOOR + WAF POLICY — Layer 7 web application firewall
# --------------------------------------------------------------------------
resource "azurerm_waf_policy" "main" {
  name                = local.waf_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  policy_settings {
    mode                                   = "Prevention"
    request_body_check                     = true
    file_upload_limit_mb                   = 100
    max_request_body_size_in_kb            = 128
  }
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        rule {
          id      = "942110"
          enabled = true
          action  = "Block"
        }
        rule {
          id      = "942120"
          enabled = true
          action  = "Block"
        }
        rule {
          id      = "942210"
          enabled = true
          action  = "Block"
        }
      }
      rule_group_override {
        rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        rule {
          id      = "941110"
          enabled = true
          action  = "Block"
        }
        rule {
          id      = "941120"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
  custom_rules {
    name                  = "RateLimit"
    priority              = 1
    rule_type             = "RateLimitRule"
    rate_limit_duration   = "OneMin"
    rate_limit_threshold  = 200
    action                = "Block"
    match_condition {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator = "IPMatch"
      match_values = ["*"]
    }
  }
  tags = local.tags
}

resource "azurerm_frontdoor" "main" {
  name                = local.fd_name
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
  }

  backend_pool {
    name = "${var.prefix}-backend"
    backend {
      host_header = azurerm_public_ip.web.ip_address
      address     = azurerm_public_ip.web.ip_address
      http_port   = 80
      https_port  = 443
    }
    load_balancing_name = "${var.prefix}-lb"
    health_probe_name   = "${var.prefix}-hp"
  }

  frontend_endpoint {
    name      = "${var.prefix}-frontend"
    host_name = "${local.fd_name}.azurefd.net"
    session_affinity_enabled = false
    web_application_firewall_policy_link_id = azurerm_waf_policy.main.id
  }

  backend_pool_health_probe {
    name                = "${var.prefix}-hp"
    enabled             = true
    path                = "/"
    protocol            = "Http"
    probe_method        = "GET"
    interval_in_seconds = 30
  }

  backend_pool_load_balancing {
    name = "${var.prefix}-lb"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }

  routing_rule {
    name               = "${var.prefix}-rule"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["${var.prefix}-frontend"]
    forwarding_configuration {
      backend_pool_name                     = "${var.prefix}-backend"
      cache_enabled                         = true
      cache_use_dynamic_compression         = true
      forwarding_protocol                   = "HttpOnly"
    }
  }
}

# --------------------------------------------------------------------------
# DEFENDER FOR CLOUD — Foundational CSPM (free)
# --------------------------------------------------------------------------
resource "azurerm_security_center_subscription_pricing" "main" {
  tier          = "Free"
  resource_type = "VirtualMachines"
}
