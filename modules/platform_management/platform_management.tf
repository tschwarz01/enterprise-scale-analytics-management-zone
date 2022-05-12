resource "azurerm_resource_group" "rg" {
  name     = var.common_module_params.resource_groups.management_resource_group
  location = var.common_module_params.location
}

module "law" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source                   = "./log_analytics_workspace"
  management_module_params = var.management_module_params
  common_module_params     = var.common_module_params

}

output "resource_group_name" {
  value = module.law.law_resource_group_name
}

output "log_analytics_name" {
  value = module.law.law_name
}

output "log_analytics_location" {
  value = module.law.law_location
}

output "log_analytics_id" {
  value = module.law.law_id
}

output "log_analytics_workspace_id" {
  value = module.law.law_workspace_id
}

output "log_analytics_primary_shared_key" {
  value = module.law.law_primary_shared_key
}
