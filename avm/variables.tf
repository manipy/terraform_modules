variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "resource_group_location" {
  description = "Location for the resource group"
  type        = string
}

variable "vms" {
  description = "Map of VM configurations where key is the VM name and value contains VM specifications"
  type = map(object({
    vm_size                = string
    subnet_name            = string
    vnet_name              = string
    private_ip_allocation  = optional(string, "Dynamic")
    admin_username         = string
    admin_password         = string
    os_type                = string  # "linux" or "windows"
    os_disk_storage_type   = string
    os_disk_size_gb        = number
    os_publisher           = string
    os_offer               = string
    os_sku                 = string
    os_version             = string
    custom_script          = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
