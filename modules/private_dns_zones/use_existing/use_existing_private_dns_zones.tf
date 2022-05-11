terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "=3.1.0"
      configuration_aliases = [azurerm.dnssub]
    }
  }
}

data "azurerm_resources" "dns-zones" {
  provider            = azurerm.dnssub
  type                = "Microsoft.Network/privateDnsZones"
  resource_group_name = var.private_dns_zone_module_params.existing_private_dns_zone_resource_group_name
}

output "private-dns-zones" {
  value = data.azurerm_resources.dns-zones
}
