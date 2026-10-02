# Example variables file
# Copy this to terraform.tfvars and update with your values

variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "my-resource-group"
}

variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
  default     = "eastus"
}

# You can override these in terraform.tfvars or pass them as command-line arguments
# terraform apply -var="resource_group_name=your-rg-name" -var="resource_group_location=eastus"
