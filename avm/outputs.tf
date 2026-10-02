output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "linux_vm_ids" {
  description = "Map of Linux VM IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "windows_vm_ids" {
  description = "Map of Windows VM IDs"
  value       = { for k, v in azurerm_windows_virtual_machine.vm : k => v.id }
}

output "vm_ids" {
  description = "Map of all VM IDs (Linux and Windows)"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.vm : k => v.id },
    { for k, v in azurerm_windows_virtual_machine.vm : k => v.id }
  )
}

output "vm_names" {
  description = "List of all VM names"
  value = concat(
    keys(azurerm_linux_virtual_machine.vm),
    keys(azurerm_windows_virtual_machine.vm)
  )
}

output "vm_private_ips" {
  description = "Map of VM private IP addresses"
  value = {
    for k, v in azurerm_network_interface.nic : k => v.private_ip_address
  }
}

output "nic_ids" {
  description = "Map of Network Interface IDs"
  value       = { for k, v in azurerm_network_interface.nic : k => v.id }
}

output "vm_locations" {
  description = "Map of VM locations"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.vm : k => v.location },
    { for k, v in azurerm_windows_virtual_machine.vm : k => v.location }
  )
}
