output "resource_group_name" {
  description = "Name of the resource group for this module."
  value       = azurerm_resource_group.main.name
}

output "vnet_name" {
  description = "Name of the created VNet."
  value       = azurerm_virtual_network.main.name
}

output "subnet_access_cidr" {
  description = "CIDR of the access subnet (Access Layer)."
  value       = var.ip_ranges.access
}

output "subnet_distribution_cidr" {
  description = "CIDR of the distribution subnet."
  value       = var.ip_ranges.distribution
}

output "subnet_core_cidr" {
  description = "CIDR of the core subnet."
  value       = var.ip_ranges.core
}

output "bastion_public_ip" {
  description = "Public IP of the bastion VM."
  value       = var.enable_bastion ? azurerm_public_ip.bastion[0].ip_address : "N/A"
}

output "bastion_ssh_command" {
  description = "SSH command for bastion access."
  value       = var.enable_bastion ? "ssh ${var.admin_username}@${azurerm_public_ip.bastion[0].ip_address}" : "N/A"
}

output "bastion_password" {
  description = "Admin password for the bastion VM. Save this — it won't be shown again."
  value       = local.admin_password
  sensitive   = true
}

output "cost_warning" {
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ NAT Gateway: ~$1.08/day (NOT free tier eligible)    ║
    ║ B1s bastion: free (750 hrs/month free tier)         ║
    ║                                                      ║
    ║ Run 'terraform destroy' when done to avoid charges.  ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
