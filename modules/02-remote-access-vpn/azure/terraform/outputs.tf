output "vpn_gateway_name" {
  description = "Name of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.main.name
}

output "vpn_gateway_public_ip" {
  description = "Public IP of the VPN Gateway."
  value       = azurerm_public_ip.vpn.ip_address
}

output "workload_vm_private_ip" {
  description = "Private IP of the workload VM."
  value       = azurerm_network_interface.workload.private_ip_address
}

output "workload_vm_password" {
  description = "Admin password for the workload VM (sensitive)."
  value       = random_password.admin.result
  sensitive   = true
}

output "vpn_client_config_command" {
  description = "Command to download the VPN client configuration."
  value = <<-EOT
    # Generate the VPN client configuration
    # From Azure Portal: Virtual Network Gateway → Point-to-site configuration → Download VPN client
    # Or use the Azure CLI:
    az network vpn-client generate \
      --resource-group ${local.rg_name} \
      --name ${azurerm_virtual_network_gateway.main.name}

    # Extract the root certificate for client setup
    # The generated zip file contains the VPN client configuration XML
    # Import the root certificate to your client machine's certificate store

    # From a VPN-connected machine, test connectivity:
    ping ${azurerm_network_interface.workload.private_ip_address}
  EOT
}

output "cost_warning" {
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ VPN Gateway (VpnGw1): ~$0.03/hr ($0.72/day)        ║
    ║   NOT free tier eligible                             ║
    ║ B1s workload VM: free (750 hrs/month)               ║
    ║                                                      ║
    ║ Strategy: 2-hour session = $0.06. Destroy after.     ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
