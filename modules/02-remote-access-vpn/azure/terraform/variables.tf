variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "creator" {
  description = "Your email for cost tracking."
  type        = string
  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator required."
  }
}

variable "destroy_after" {
  type    = string
  default = "2026-08-20"
}

variable "module_name" {
  type    = string
  default = "02-remote-access-vpn"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = string
  default     = "10.0.0.0/16"
}
