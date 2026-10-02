# Example usage of the AVM module
# This demonstrates how application teams can invoke the module to create multiple VMs

provider "azurerm" {
  features {}
}

# Example 1: Create multiple Linux web servers with identical configuration
module "web_servers" {
  source = "../../avm"

  resource_group_name     = "my-resource-group"
  resource_group_location = "eastus"

  vms = {
    "webserver-01" = {
      vm_size                = "Standard_DS1_v2"
      subnet_name            = "web-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "linux"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 30
      os_publisher           = "Canonical"
      os_offer               = "0001-com-ubuntu-server-jammy"
      os_sku                 = "22_04-lts-gen2"
      os_version             = "latest"
      custom_script          = "sudo apt-get update && sudo apt-get install -y nginx"
    },
    "webserver-02" = {
      vm_size                = "Standard_DS1_v2"
      subnet_name            = "web-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "linux"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 30
      os_publisher           = "Canonical"
      os_offer               = "0001-com-ubuntu-server-jammy"
      os_sku                 = "22_04-lts-gen2"
      os_version             = "latest"
      custom_script          = "sudo apt-get update && sudo apt-get install -y nginx"
    },
    "webserver-03" = {
      vm_size                = "Standard_DS1_v2"
      subnet_name            = "web-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "linux"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 30
      os_publisher           = "Canonical"
      os_offer               = "0001-com-ubuntu-server-jammy"
      os_sku                 = "22_04-lts-gen2"
      os_version             = "latest"
      custom_script          = "sudo apt-get update && sudo apt-get install -y nginx"
    }
  }

  tags = {
    Environment = "Production"
    Application = "WebApp"
    Team        = "PlatformEngineering"
  }
}

# Example 2: Create VMs with different configurations (app server, database server)
module "application_servers" {
  source = "../../avm"

  resource_group_name     = "my-resource-group"
  resource_group_location = "eastus"

  vms = {
    "app-server-01" = {
      vm_size                = "Standard_DS2_v2"
      subnet_name            = "app-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "linux"
      os_disk_storage_type   = "Standard_LRS"
      os_disk_size_gb        = 32
      os_publisher           = "Canonical"
      os_offer               = "0001-com-ubuntu-server-jammy"
      os_sku                 = "22_04-lts-gen2"
      os_version             = "latest"
      custom_script          = "sudo apt-get update && sudo apt-get install -y docker.io docker-compose"
    },
    "db-server-01" = {
      vm_size                = "Standard_DS3_v2"
      subnet_name            = "db-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "linux"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 128
      os_publisher           = "Canonical"
      os_offer               = "0001-com-ubuntu-server-jammy"
      os_sku                 = "22_04-lts-gen2"
      os_version             = "latest"
      custom_script          = "sudo apt-get update && sudo apt-get install -y postgresql"
    }
  }

  tags = {
    Environment = "Production"
    Application = "DatabaseApp"
    Team        = "DataEngineering"
  }
}

# Example 3: Create Windows VMs
module "windows_servers" {
  source = "../../avm"

  resource_group_name     = "my-resource-group"
  resource_group_location = "eastus"

  vms = {
    "win-webserver-01" = {
      vm_size                = "Standard_DS2_v2"
      subnet_name            = "web-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "windows"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 127
      os_publisher           = "MicrosoftWindowsServer"
      os_offer               = "WindowsServer"
      os_sku                 = "2019-Datacenter"
      os_version             = "latest"
      custom_script          = "Install-WindowsFeature -name Web-Server -IncludeManagementTools"
    },
    "win-appserver-01" = {
      vm_size                = "Standard_DS3_v2"
      subnet_name            = "app-subnet"
      vnet_name              = "my-vnet"
      admin_username         = "azureuser"
      admin_password         = "P@ssw0rd123!"
      os_type                = "windows"
      os_disk_storage_type   = "Premium_LRS"
      os_disk_size_gb        = 127
      os_publisher           = "MicrosoftWindowsServer"
      os_offer               = "WindowsServer"
      os_sku                 = "2022-Datacenter"
      os_version             = "latest"
      custom_script          = "Install-WindowsFeature -name NET-Framework-45-Core -IncludeManagementTools"
    }
  }

  tags = {
    Environment = "Production"
    Application = "WindowsApp"
    Team        = "WindowsTeam"
  }
}

# Output the VM details
output "web_server_ids" {
  description = "IDs of the web servers"
  value       = module.web_servers.vm_ids
}

output "web_server_private_ips" {
  description = "Private IPs of the web servers"
  value       = module.web_servers.vm_private_ips
}

output "app_server_ids" {
  description = "IDs of the application servers"
  value       = module.application_servers.vm_ids
}

output "app_server_private_ips" {
  description = "Private IPs of the application servers"
  value       = module.application_servers.vm_private_ips
}

output "windows_server_ids" {
  description = "IDs of the Windows servers"
  value       = module.windows_servers.vm_ids
}

output "windows_server_private_ips" {
  description = "Private IPs of the Windows servers"
  value       = module.windows_servers.vm_private_ips
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.web_servers.resource_group_id
}
