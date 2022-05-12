resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.common_module_params.resource_prefix}-integration"
  location = var.common_module_params.location
}


module "data-factory-module" {
  depends_on                 = [azurerm_resource_group.rg]
  count                      = var.integration_module_params.deploy_adf ? 1 : 0
  source                     = "./adf"
  common_module_params       = var.common_module_params
  data_factory_module_params = local.data_factory_module_params
}

module "adf-shir" {
  depends_on             = [module.data-factory-module]
  count                  = var.integration_module_params.deploy_adf_shir ? 1 : 0
  source                 = "./adf_shir"
  common_module_params   = var.common_module_params
  adf_shir_module_params = local.adf_shir_module_params
}

resource "time_sleep" "delay" {
  depends_on      = [module.adf-shir]
  create_duration = "60s"
}

module "aci-devops-agent" {
  depends_on           = [time_sleep.delay]
  count                = var.devops_agent_params.deploy_aci_hosted_azure_devops_agents ? 1 : 0
  source               = "./aci_devops_agent"
  devops_agent_params  = var.devops_agent_params
  common_module_params = var.common_module_params
}

