resource "azurerm_data_factory" "dataFactory" {
  name                            = var.data_factory_module_params.name
  location                        = var.data_factory_module_params.location
  resource_group_name             = var.data_factory_module_params.resource_group_name
  public_network_enabled          = var.data_factory_module_params.publicNetworkEnabled
  managed_virtual_network_enabled = var.data_factory_module_params.managedVnetEnabled
  tags                            = var.data_factory_module_params.tags
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_integration_runtime_azure" "adfManagedIntegrationRuntime" {
  name                    = var.data_factory_module_params.managed_integration_runtime_name
  location                = var.data_factory_module_params.location
  data_factory_id         = azurerm_data_factory.dataFactory.id
  virtual_network_enabled = var.data_factory_module_params.managedVnetEnabled

  depends_on = [
    azurerm_data_factory.dataFactory
  ]
}



resource "azurerm_private_endpoint" "privateEndpoint" {
  for_each            = local.privateEndpoints
  name                = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]
  subnet_id           = each.value["subnet_id"]

  private_service_connection {
    name                           = each.value["peServiceConnectionName"]
    private_connection_resource_id = azurerm_data_factory.dataFactory.id
    subresource_names              = each.value["peSubresourceNames"]
    is_manual_connection           = each.value["peIsManualConnection"]
  }

  private_dns_zone_group {
    name                 = "ZoneGroup"
    private_dns_zone_ids = each.value["private_dns_zone_ids"]
  }
  depends_on = [
    azurerm_data_factory.dataFactory
  ]
}

output "dataFactoryModuleOutput" {
  value = {
    dataFactoryId = azurerm_data_factory.dataFactory.id
  }

}
