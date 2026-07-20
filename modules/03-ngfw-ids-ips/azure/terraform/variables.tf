variable "prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "sdci-03-az"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "creator" {
  description = "Your email for cost tracking."
  type        = string
}

variable "destroy_after" {
  type    = string
  default = "2026-08-20"
}

variable "module_name" {
  type    = string
  default = "03-ngfw-ids-ips"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
