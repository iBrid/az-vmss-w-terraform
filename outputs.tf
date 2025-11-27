output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.vmss.name
}

output "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  value       = azurerm_windows_virtual_machine_scale_set.vmss.name
}

output "vmss_id" {
  description = "ID of the Virtual Machine Scale Set"
  value       = azurerm_windows_virtual_machine_scale_set.vmss.id
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.vmss.ip_address
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vmss.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.vmss.id
}
