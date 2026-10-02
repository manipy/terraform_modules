# Azure Virtual Machine (AVM) Terraform Module

A generic, reusable Terraform module for creating Azure Virtual Machines using `for_each` loops and maps. This module allows any application team to create multiple VMs with different configurations in a single deployment, supporting both Linux and Windows operating systems.

## Features

- **Generic Design**: Works for any application team with configurable parameters
- **For Each Loop**: Create multiple VMs in a single deployment
- **Map-based Configuration**: Use maps to define VM specifications
- **Flexible Configuration**: Support for different VM sizes, OS images, and storage types
- **Multi-OS Support**: Create both Linux and Windows VMs in the same deployment
- **Resource Group Creation**: Automatically creates the resource group
- **Automatic IP Assignment**: IPs are automatically assigned from the subnet (dynamic allocation by default)
- **Custom Script Extension**: Execute custom scripts during VM provisioning
- **Networking**: Automatically creates network interfaces and connects to existing subnets
- **Tags Support**: Apply common tags across all resources

## Module Structure

```
terraform_modules/avm/
├── main.tf       # Main resource definitions
├── variables.tf  # Input variables
├── outputs.tf    # Output values
├── versions.tf   # Provider and Terraform version constraints
├── providers.tf  # Provider configuration
├── data.tf       # Data sources
└── README.md     # This file
```

## Usage Example

### Basic Usage (Linux VMs)

```hcl
provider "azurerm" {
  features {}
}

module "avm" {
  source = "../terraform_modules/avm"

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
    }
  }

  tags = {
    Environment = "Production"
    Application = "WebApp"
    Team        = "PlatformEngineering"
  }
}
```

### Windows VMs

```hcl
module "avm" {
  source = "../terraform_modules/avm"

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
    }
  }

  tags = {
    Environment = "Production"
    Application = "WindowsWebApp"
  }
}
```

### Mixed Linux and Windows VMs

```hcl
module "avm" {
  source = "../terraform_modules/avm"

  resource_group_name     = "my-resource-group"
  resource_group_location = "eastus"

  vms = {
    "linux-webserver" = {
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
    "windows-appserver" = {
      vm_size                = "Standard_DS2_v2"
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
    Application = "MixedEnvironment"
  }
}
```

## Inputs

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `resource_group_name` | string | Name of the resource group to create | - |
| `resource_group_location` | string | Location for the resource group | - |
| `vms` | map(object) | Map of VM configurations where key is the VM name | `{}` |
| `tags` | map(string) | Common tags to apply to all resources | `{Environment = "Production", ManagedBy = "Terraform"}` |

### VM Configuration Object

Each VM in the `vms` map requires the following attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `vm_size` | string | Azure VM size (e.g., "Standard_DS1_v2") |
| `subnet_name` | string | Name of the subnet to connect to |
| `vnet_name` | string | Name of the virtual network |
| `private_ip_allocation` | string | IP allocation method: "Static" or "Dynamic" (default: "Dynamic") |
| `private_ip_address` | string | Static IP address (only required if allocation is Static) |
| `admin_username` | string | Admin username for the VM |
| `admin_password` | string | Admin password for the VM |
| `os_type` | string | Operating system type: "linux" or "windows" |
| `os_disk_storage_type` | string | Storage type: "Standard_LRS", "Premium_LRS", etc. |
| `os_disk_size_gb` | number | OS disk size in GB |
| `os_publisher` | string | OS image publisher |
| `os_offer` | string | OS image offer |
| `os_sku` | string | OS image SKU |
| `os_version` | string | OS image version |
| `custom_script` | string | Custom script to execute during provisioning |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resource_group_id` | string | ID of the created resource group |
| `resource_group_name` | string | Name of the created resource group |
| `linux_vm_ids` | map(string) | Map of Linux VM IDs |
| `windows_vm_ids` | map(string) | Map of Windows VM IDs |
| `vm_ids` | map(string) | Map of all VM IDs (Linux and Windows) |
| `vm_names` | list(string) | List of all VM names |
| `vm_private_ips` | map(string) | Map of VM private IP addresses |
| `nic_ids` | map(string) | Map of Network Interface IDs |
| `vm_locations` | map(string) | Map of VM locations |

## Common OS Image References

### Ubuntu
```hcl
os_publisher = "Canonical"
os_offer     = "0001-com-ubuntu-server-jammy"
os_sku       = "22_04-lts-gen2"
os_version   = "latest"
```

### Windows Server 2019
```hcl
os_publisher = "MicrosoftWindowsServer"
os_offer     = "WindowsServer"
os_sku       = "2019-Datacenter"
os_version   = "latest"
```

### Windows Server 2022
```hcl
os_publisher = "MicrosoftWindowsServer"
os_offer     = "WindowsServer"
os_sku       = "2022-Datacenter"
os_version   = "latest"
```

### CentOS
```hcl
os_publisher = "OpenLogic"
os_offer     = "CentOS"
os_sku       = "7_9-gen2"
os_version   = "latest"
```

## Common VM Sizes

| Size | vCPUs | RAM | Use Case |
|------|-------|-----|----------|
| Standard_DS1_v2 | 1 | 3.5 GB | Development/Testing |
| Standard_DS2_v2 | 2 | 7 GB | Small workloads |
| Standard_DS3_v2 | 4 | 14 GB | Medium workloads |
| Standard_DS4_v2 | 8 | 28 GB | Large workloads |
| Standard_F2s_v2 | 2 | 4 GB | General purpose |

## Prerequisites

1. Existing Virtual Network with subnets
2. Azure CLI installed and authenticated
3. Terraform >= 1.0.0

## Deployment Steps

1. Clone or copy this module to your Terraform project
2. Create a main.tf file with your configuration
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Best Practices

1. **Use Managed Identity**: Consider using managed identity instead of username/password
2. **Network Security Groups**: Apply NSGs to restrict traffic
3. **Backup**: Enable Azure Backup for critical VMs
4. **Monitoring**: Configure Azure Monitor and alerts
5. **SSH Keys**: Use SSH keys instead of passwords for Linux VMs
6. **Custom Scripts**: Keep custom scripts in a storage account for better management
7. **OS Type**: Always specify `os_type` as "linux" or "windows" to ensure correct VM creation
8. **Custom Script Format**: Use bash commands for Linux and PowerShell commands for Windows

## License

This module is provided as-is for use in your infrastructure deployments.
