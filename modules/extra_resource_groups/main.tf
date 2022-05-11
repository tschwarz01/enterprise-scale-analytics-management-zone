locals {
  resource_group_names = [
    var.common_module_params.resource_groups.marketplace_resource_group,
    var.common_module_params.resource_groups.service_layer_resource_group,
    var.common_module_params.resource_groups.mesh_service_layer_resource_group,
    var.common_module_params.resource_groups.automation_resource_group,
    var.common_module_params.resource_groups.shared_services_resource_group
  ]
}

resource "azurerm_resource_group" "extra-resource-groups" {
  count    = length(local.resource_group_names)
  name     = local.resource_group_names[count.index]
  location = var.common_module_params.location
  tags     = var.common_module_params.tags
}
