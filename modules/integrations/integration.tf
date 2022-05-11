resource "azurerm_resource_group" "integration-resource-group" {
  name     = "rg-${var.common_module_params.resource_prefix}-integration"
  location = var.common_module_params.location
}


module "dataFactoryModule" {
  depends_on                 = [azurerm_resource_group.integration-resource-group]
  count                      = var.integration_module_params.deploy_adf ? 1 : 0
  source                     = "./adf"
  common_module_params       = var.common_module_params
  data_factory_module_params = local.data_factory_module_params

}

module "adfShir" {
  depends_on             = [module.dataFactoryModule]
  count                  = var.integration_module_params.deploy_adf_shir ? 1 : 0
  source                 = "./adf_shir"
  common_module_params   = var.common_module_params
  adf_shir_module_params = local.adf_shir_module_params
}

resource "time_sleep" "delay" {
  depends_on      = [module.adfShir]
  create_duration = "60s"
}

module "aciDevOpsAgent" {
  depends_on           = [time_sleep.delay]
  count                = var.devops_agent_params.deploy_aci_hosted_azure_devops_agents ? 1 : 0
  source               = "./aci_devops_agent"
  devops_agent_params  = var.devops_agent_params
  common_module_params = var.common_module_params
}

