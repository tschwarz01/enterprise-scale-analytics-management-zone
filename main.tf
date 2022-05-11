data "azurerm_client_config" "tfazconfig" {}



module "data-mgmt-landing-zone-resource-groups-future-expansion" {
  source               = "./modules/extra_resource_groups"
  common_module_params = local.common_module_params
}

module "network-services-module" {
  source                = "./modules/network_services"
  network_module_params = local.network_module_params
  common_module_params  = local.common_module_params
  providers = {
    azurerm        = azurerm
    azurerm.hubsub = azurerm.hubsub
  }
}

module "use-existing-private-dns-zones" {
  depends_on                     = [module.network-services-module]
  count                          = var.use_existing_private_dns_zones_from_remote_subscription ? 1 : 0
  source                         = "./modules/private_dns_zones/use_existing"
  private_dns_zone_module_params = local.private_dns_zone_module_params
  common_module_params           = local.common_module_params
  providers = {
    azurerm        = azurerm
    azurerm.dnssub = azurerm.dnssub
  }
}

module "deploy-private-dns-zones" {
  depends_on                         = [module.network-services-module]
  count                              = var.use_existing_private_dns_zones_from_remote_subscription ? 0 : 1
  source                             = "./modules/private_dns_zones/create_new"
  new_private_dns_zone_module_params = local.new_private_dns_zone_module_params
  common_module_params               = local.common_module_params
}

// Need to figure out Azure Policy for service diagnostics
module "management-module" {
  source                   = "./modules/platform_management"
  management_module_params = local.management_module_params
  common_module_params     = local.common_module_params
}

// Azure Purview & KeyVault for Purview
// MDM / DQ / Contracts / API Catalog
module "data-governance-module" {
  source                        = "./modules/data_governance"
  common_module_params          = local.common_module_params
  data_governance_module_params = local.data_governance_module_params
}

// Integration Agents
// GitHub Action Runners - ToDo
// DevOps Agent
// -- Create ACR
// -- Deploy Azure DevOps Agent docker image & Deploy to ACI
//      https://github.com/Azure/terraform-azurerm-aci-devops-agent/tree/master/docker/linux,
//      https://registry.terraform.io/modules/Azure/aci-devops-agent/azurerm/latest,
//      https://jamescook.dev/azuredevops-linux-agent-install-using-terraform
// Purview Self-Hosted Integration Runtime (appears to not be possible with tf at this time)
// Azure Data Factory Self-Hosted Integration Runtimes # DONE
// Azure Data Factory - to be primary "owner" of the above SHIRs (enabling CICD) # DONE

module "integration-module" {
  source                    = "./modules/integrations"
  common_module_params      = local.common_module_params
  integration_module_params = local.integration_module_params
  devops_agent_params       = local.devops_agent_params
  adf_shir_module_params    = local.adf_shir_module_params
  depends_on                = [module.consumption-module]
}

// Consumption
// Azure based data gateways
// Container Registry
// Shared Image Gallery
// Synapse Link
module "consumption-module" {
  source                    = "./modules/consumption"
  common_module_params      = local.common_module_params
  devops_agent_params       = local.devops_agent_params
  consumption_module_params = local.consumption_module_params
}


