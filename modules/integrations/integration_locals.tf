

locals {
  data_factory_module_params = {
    name                             = "${var.common_module_params.resource_prefix}-shared-data-factory"
    location                         = var.common_module_params.location
    resource_group_name              = azurerm_resource_group.integration-resource-group.name
    publicNetworkEnabled             = var.integration_module_params.adf_enable_public_network
    managedVnetEnabled               = var.integration_module_params.adf_managed_virtual_network_enabled
    tags                             = var.common_module_params.tags
    managed_integration_runtime_name = "${var.common_module_params.resource_prefix}-adf-managed-ir"
    private_endpoint_subnet_id       = var.integration_module_params.private_endpoint_subnet_id
    adf_factory_private_dns_zone_id  = var.integration_module_params.adf_factory_private_dns_zone_id
    adf_portal_private_dns_zone_id   = var.integration_module_params.adf_portal_private_dns_zone_id
  }
  adf_shir_module_params = {
    adf_shir_install_script      = var.adf_shir_module_params.adf_shir_install_script
    adf_shir_subnet_id           = var.adf_shir_module_params.adf_shir_subnet_id
    adf_shir_vmss_sku            = var.adf_shir_module_params.adf_shir_vmss_sku
    adf_shir_vmss_username       = var.adf_shir_module_params.adf_shir_vmss_username
    adf_shir_vmss_password       = var.adf_shir_module_params.adf_shir_vmss_password
    adf_shir_vmss_instance_count = var.adf_shir_module_params.adf_shir_vmss_instance_count
    dataFactoryId                = module.dataFactoryModule[0].dataFactoryModuleOutput.dataFactoryId
  }

}



