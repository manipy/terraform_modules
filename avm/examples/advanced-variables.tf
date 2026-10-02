variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
