locals {
  subnet_map_temp = {
    firewall = {
      name                                = "${var.common_module_params.resource_prefix}-firewall-subnet"
      address_prefix                      = [var.network_module_params.azure_firewall_subnet_address_prefix]
      allow_private_endpoints             = false
      allow_privatelink_service_endpoints = false
      should_create                       = false
      has_service_delegation              = false
    }
    "services" = {
      name                                = "${var.common_module_params.resource_prefix}-services-subnet"
      address_prefix                      = [var.network_module_params.services_subnet_address_prefix]
      allow_private_endpoints             = true
      allow_privatelink_service_endpoints = true
      should_create                       = true
      has_service_delegation              = false
    }
    "gateway" = {
      name                                = "GatewaySubnet"
      address_prefix                      = [var.network_module_params.gateway_subnet_address_prefix]
      allow_private_endpoints             = false
      allow_privatelink_service_endpoints = false
      should_create                       = false
      has_service_delegation              = false
    }
    "aci" = {
      name                                = "${var.common_module_params.resource_prefix}-aci-subnet"
      address_prefix                      = [var.network_module_params.aci_subnet_address_prefix]
      allow_private_endpoints             = false
      allow_privatelink_service_endpoints = false
      should_create                       = var.network_module_params.deploy_aci_subnet
      has_service_delegation              = true
      delegation_name                     = "acidelegation"
      service_delegation_name             = "Microsoft.ContainerInstance/containerGroups"
      service_delegation_actions          = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
    "cicd" = {
      name                                = "${var.common_module_params.resource_prefix}-cicd-iaas-subnet"
      address_prefix                      = [var.network_module_params.cicd_subnet_address_prefix]
      allow_private_endpoints             = false
      allow_privatelink_service_endpoints = false
      should_create                       = var.network_module_params.deploy_cicd_iaas_agents_subnet
      has_service_delegation              = false
    }
  }
  subnet_map = {
    for key, val in local.subnet_map_temp : key => val if val.should_create == true
  }
}


locals {
  vnet_peerings = {
    dmlz-to-connectivity-hub = {
      name                         = "${var.common_module_params.resource_prefix}-dmlz-to-hub-peering"
      resource_group_name          = var.network_module_params.network_resource_group
      virtual_network_name         = azurerm_virtual_network.dmlz-virtual-network.name
      remote_virtual_network_id    = var.network_module_params.connectivity_hub_virtual_network_id
      peer_use_remote_gateways     = true
      allow_virtual_network_access = true
      allow-forwarded-traffic      = true
      peer_allow_gateway_transit   = false
    }
    connectivity_hub_to_dmlz = {
      name                         = "${var.common_module_params.resource_prefix}-hub-to-dmlz-peering"
      resource_group_name          = local.connectivity_hub_vnet_resource_group_name
      virtual_network_name         = local.connectivity_hub_vnet_name
      remote_virtual_network_id    = azurerm_virtual_network.dmlz-virtual-network.id
      allow_virtual_network_access = true
      allow-forwarded-traffic      = true
      peer_allow_gateway_transit   = true
      peer_use_remote_gateways     = false
    }
  }
  connectivity_hub_vnet_resource_group_name = element(split("/", var.network_module_params.connectivity_hub_virtual_network_id), 4)
  connectivity_hub_vnet_name                = element(split("/", var.network_module_params.connectivity_hub_virtual_network_id), length(split("/", var.network_module_params.connectivity_hub_virtual_network_id)) - 1)
  connectivity_hub_vnet_subscription_id     = element(split("/", var.network_module_params.connectivity_hub_virtual_network_id), 2)
}
