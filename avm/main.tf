resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.tags
}

resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing[each.key].id
    private_ip_address_allocation = each.value.private_ip_allocation
    private_ip_address            = each.value.private_ip_allocation == "Static" ? each.value.private_ip_address : null
  }

  tags = merge(var.tags, {
    Name = "${each.key}-nic"
  })
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "linux" }

  name                            = each.key
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_storage_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = each.value.os_publisher
    offer     = each.value.os_offer
    sku       = each.value.os_sku
    version   = each.value.os_version
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "windows" }

  name                  = each.key
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_storage_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = each.value.os_publisher
    offer     = each.value.os_offer
    sku       = each.value.os_sku
    version   = each.value.os_version
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "azurerm_virtual_machine_extension" "custom_script_linux" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "linux" }

  name                 = "${each.key}-custom-script"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    "commandToExecute" = each.value.custom_script
  })

  lifecycle {
    ignore_changes = [settings]
  }
}

resource "azurerm_virtual_machine_extension" "custom_script_windows" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "windows" }

  name                 = "${each.key}-custom-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    "commandToExecute" = each.value.custom_script
  })

  lifecycle {
    ignore_changes = [settings]
  }
}
