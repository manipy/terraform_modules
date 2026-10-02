# Advanced example using locals and variables for more flexible configuration
# This demonstrates how to use Terraform features to reduce duplication

provider "azurerm" {
  features {}
}

# Define common VM configurations using locals
locals {
  common_vm_config = {
    admin_username         = "azureuser"
    admin_password         = "P@ssw0rd123!"
    os_type                = "linux"
    os_publisher           = "Canonical"
    os_offer               = "0001-com-ubuntu-server-jammy"
    os_sku                 = "22_04-lts-gen2"
    os_version             = "latest"
    vnet_name              = "my-vnet"
    private_ip_allocation  = "Dynamic"
  }

  web_server_config = merge(local.common_vm_config, {
    vm_size                = "Standard_DS1_v2"
    subnet_name            = "web-subnet"
    os_disk_storage_type   = "Premium_LRS"
    os_disk_size_gb        = 30
    custom_script          = "sudo apt-get update && sudo apt-get install -y nginx"
  })

  app_server_config = merge(local.common_vm_config, {
    vm_size                = "Standard_DS2_v2"
    subnet_name            = "app-subnet"
    os_disk_storage_type   = "Standard_LRS"
    os_disk_size_gb        = 32
    custom_script          = "sudo apt-get update && sudo apt-get install -y docker.io"
  })

  windows_server_config = {
    admin_username         = "azureuser"
    admin_password         = "P@ssw0rd123!"
    os_type                = "windows"
    os_publisher           = "MicrosoftWindowsServer"
    os_offer               = "WindowsServer"
    os_sku                 = "2019-Datacenter"
    os_version             = "latest"
    vnet_name              = "my-vnet"
    vm_size                = "Standard_DS2_v2"
    subnet_name            = "web-subnet"
    os_disk_storage_type   = "Premium_LRS"
    os_disk_size_gb        = 127
    custom_script          = "Install-WindowsFeature -name Web-Server -IncludeManagementTools"
  }
}

# Generate web server configurations with sequential IPs
module "web_servers" {
  source = "../../avm"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    for i in range(1, 4) : "webserver-${format("%02d", i)}" => local.web_server_config
  }

  tags = merge(var.common_tags, {
    Application = "WebApp"
    Tier        = "Frontend"
  })
}

# Generate application server configurations
module "app_servers" {
  source = "../../avm"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    "app-server-01" = local.app_server_config,
    "app-server-02" = local.app_server_config
  }

  tags = merge(var.common_tags, {
    Application = "APIApp"
    Tier        = "Backend"
  })
}

# Database server with different configuration
module "db_servers" {
  source = "../../avm"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    "db-server-01" = merge(local.common_vm_config, {
      vm_size                = "Standard_DS4_v2"
      subnet_name            = "db-subnet"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 256
      custom_script          = "sudo apt-get update && sudo apt-get install -y postgresql"
    })
  }

  tags = merge(var.common_tags, {
    Application = "Database"
    Tier        = "Data"
  })
}

# Windows server example
module "windows_servers" {
  source = "../../avm"

  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location

  vms = {
    "win-webserver-01" = local.windows_server_config
  }

  tags = merge(var.common_tags, {
    Application = "WindowsWebApp"
    Tier        = "Frontend"
  })
}

output "all_vm_ids" {
  description = "All VM IDs across all modules"
  value = merge(
    module.web_servers.vm_ids,
    module.app_servers.vm_ids,
    module.db_servers.vm_ids,
    module.windows_servers.vm_ids
  )
}

output "all_vm_private_ips" {
  description = "All VM private IPs across all modules"
  value = merge(
    module.web_servers.vm_private_ips,
    module.app_servers.vm_private_ips,
    module.db_servers.vm_private_ips,
    module.windows_servers.vm_private_ips
  )
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.web_servers.resource_group_id
}
