resource "azurerm_resource_group" "private-dns-zone-resource-group" {
  name     = var.common_module_params.resource_groups.dns_zone_resource_group
  location = var.common_module_params.location
  tags     = var.common_module_params.tags
}


resource "azurerm_private_dns_zone" "private-dns-zones" {
  depends_on          = [azurerm_resource_group.private-dns-zone-resource-group]
  for_each            = toset(var.new_private_dns_zone_module_params.dnsZones)
  name                = each.key
  resource_group_name = azurerm_resource_group.private-dns-zone-resource-group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet-link-ex" {
  depends_on            = [azurerm_private_dns_zone.private-dns-zones]
  for_each              = azurerm_private_dns_zone.private-dns-zones
  name                  = "${each.value.name}-${var.new_private_dns_zone_module_params.virtual_network_name}-vnetlink"
  resource_group_name   = azurerm_resource_group.private-dns-zone-resource-group.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.new_private_dns_zone_module_params.virtual_network_id
}

output "private-dns-zones" {
  value = azurerm_private_dns_zone.private-dns-zones
}
