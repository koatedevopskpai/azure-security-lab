variable "location" {
  description = "Azure region for all resources (e.g., eastus, westeurope)."
  type        = string
  default     = "eastus"
  validation {
    condition     = can(regex("^[a-z]+$", var.location)) || can(regex("^[a-z]+[0-9]+$", var.location))
    error_message = "Location must be a valid Azure region (e.g., eastus, westeurope)."
  }
}

variable "creator" {
  description = "Your email or username for cost tracking."
  type        = string
  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator must not be empty."
  }
}

variable "destroy_after" {
  description = "Date by which resources should be destroyed (YYYY-MM-DD)."
  type        = string
  default     = "2026-08-20"
  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.destroy_after))
    error_message = "Must be valid YYYY-MM-DD format."
  }
}

variable "enable_bastion" {
  description = "Whether to deploy a B1s bastion VM. Free tier eligible (750 hrs/month)."
  type        = bool
  default     = true
}

variable "enable_nat" {
  description = "Whether to deploy NAT Gateway for private subnet egress. Costs ~$1.08/day, NOT free tier."
  type        = bool
  default     = true
}

variable "ip_ranges" {
  description = "CIDR ranges for the VNet and subnets."
  type = object({
    vnet         = string
    access       = string
    distribution = string
    core         = string
  })
  default = {
    vnet         = "10.0.0.0/16"
    access       = "10.0.1.0/24"
    distribution = "10.0.2.0/24"
    core         = "10.0.3.0/24"
  }
  validation {
    condition     = alltrue([can(cidrhost(var.ip_ranges.vnet, 0)), can(cidrhost(var.ip_ranges.access, 0)), can(cidrhost(var.ip_ranges.distribution, 0)), can(cidrhost(var.ip_ranges.core, 0))])
    error_message = "All IP ranges must be valid CIDR notation."
  }
}

variable "module_name" {
  description = "Module identifier for tagging."
  type        = string
  default     = "01-vnet-segmentation"
}

variable "extra_tags" {
  description = "Optional additional tags for all resources."
  type        = map(string)
  default     = {}
}

variable "admin_username" {
  description = "Admin username for the bastion VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the bastion VM (must meet Azure complexity). Auto-generated if empty."
  type        = string
  default     = ""
  sensitive   = true
}
