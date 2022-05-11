locals {
  privateEndpoints = {
    dataFactoryFactory = {
      name                          = "${var.common_module_params.resource_prefix}-adf-factory-pe"
      location                      = var.common_module_params.location
      resource_group_name           = var.data_factory_module_params.resource_group_name
      subnet_id                     = var.data_factory_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-adf-factory-pe-sc"
      peServiceConnectionResourceId = azurerm_data_factory.dataFactory.id
      peSubresourceNames            = ["dataFactory"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_factory_module_params.adf_factory_private_dns_zone_id]
    }
    dataFactoryPortal = {
      name                          = "${var.common_module_params.resource_prefix}-adf-portal-pe"
      location                      = var.common_module_params.location
      resource_group_name           = var.data_factory_module_params.resource_group_name
      subnet_id                     = var.data_factory_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-adf-portal-pe-sc"
      peServiceConnectionResourceId = azurerm_data_factory.dataFactory.id
      peSubresourceNames            = ["portal"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_factory_module_params.adf_portal_private_dns_zone_id]
    }
  }
}
