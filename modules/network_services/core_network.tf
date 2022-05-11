terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "=3.1.0"
      configuration_aliases = [azurerm.hubsub]
    }
  }
}

resource "azurerm_resource_group" "network-resource-group" {
  name     = var.common_module_params.resource_groups.network_resource_group
  location = var.common_module_params.location
  tags     = var.common_module_params.tags
}

resource "azurerm_virtual_network" "dmlz-virtual-network" {
  depends_on = [
    azurerm_resource_group.network-resource-group
  ]
  name                = "${var.common_module_params.resource_prefix}-vnetwork"
  address_space       = var.network_module_params.vnet_address_prefix
  resource_group_name = var.network_module_params.network_resource_group
  location            = azurerm_resource_group.network-resource-group.location
  tags                = var.common_module_params.tags
}

resource "azurerm_subnet" "dmlz-subnets" {
  depends_on = [
    azurerm_virtual_network.dmlz-virtual-network
  ]
  for_each                                       = local.subnet_map
  resource_group_name                            = azurerm_virtual_network.dmlz-virtual-network.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.dmlz-virtual-network.name
  name                                           = each.value.name
  address_prefixes                               = each.value.address_prefix
  enforce_private_link_endpoint_network_policies = each.value.allow_private_endpoints
  enforce_private_link_service_network_policies  = each.value.allow_privatelink_service_endpoints

  dynamic "delegation" {
    for_each = each.value.has_service_delegation == true ? [1] : []

    content {
      name = each.value.delegation_name
      service_delegation {
        name    = each.value.service_delegation_name
        actions = each.value.service_delegation_actions
      }
    }
  }
}

resource "azurerm_network_security_group" "dmlzServicesSubnetNsg" {
  resource_group_name = azurerm_virtual_network.dmlz-virtual-network.resource_group_name
  name                = "${var.common_module_params.resource_prefix}-services-subnet-nsg"
  location            = var.common_module_params.location
  tags                = var.common_module_params.tags
}

resource "azurerm_subnet_network_security_group_association" "servicesSubnetNsgAssoc" {
  subnet_id                 = azurerm_subnet.dmlz-subnets["services"].id
  network_security_group_id = azurerm_network_security_group.dmlzServicesSubnetNsg.id
  depends_on = [
    azurerm_subnet.dmlz-subnets,
    azurerm_network_security_group.dmlzServicesSubnetNsg
  ]
}

resource "azurerm_network_profile" "aci-network-profile" {
  count               = var.network_module_params.deploy_aci_subnet ? 1 : 0
  name                = "${var.common_module_params.resource_prefix}-aci-net-profile"
  location            = var.common_module_params.location
  resource_group_name = azurerm_virtual_network.dmlz-virtual-network.resource_group_name

  container_network_interface {
    name = "acinic"

    ip_configuration {
      name      = "aciipconfig"
      subnet_id = azurerm_subnet.dmlz-subnets["aci"].id
    }
  }
}

resource "azurerm_virtual_network_peering" "peer-dmlz-to-connectivity-hub" {
  count                        = var.network_module_params.peer_with_connectivity_hub ? 1 : 0
  name                         = local.vnet_peerings.dmlz-to-connectivity-hub.name
  virtual_network_name         = local.vnet_peerings.dmlz-to-connectivity-hub.virtual_network_name
  resource_group_name          = local.vnet_peerings.dmlz-to-connectivity-hub.resource_group_name
  remote_virtual_network_id    = local.vnet_peerings.dmlz-to-connectivity-hub.remote_virtual_network_id
  use_remote_gateways          = local.vnet_peerings.dmlz-to-connectivity-hub.peer_use_remote_gateways
  allow_virtual_network_access = local.vnet_peerings.dmlz-to-connectivity-hub.allow_virtual_network_access
  allow_forwarded_traffic      = local.vnet_peerings.dmlz-to-connectivity-hub.allow-forwarded-traffic
  allow_gateway_transit        = local.vnet_peerings.dmlz-to-connectivity-hub.peer_allow_gateway_transit
  depends_on = [
    azurerm_virtual_network.dmlz-virtual-network,
    azurerm_subnet.dmlz-subnets
  ]
}

resource "azurerm_virtual_network_peering" "peer-connectivity_hub_to_dmlz" {
  count                        = var.network_module_params.peer_with_connectivity_hub ? 1 : 0
  provider                     = azurerm.hubsub
  name                         = local.vnet_peerings.connectivity_hub_to_dmlz.name
  virtual_network_name         = local.vnet_peerings.connectivity_hub_to_dmlz.virtual_network_name
  resource_group_name          = local.vnet_peerings.connectivity_hub_to_dmlz.resource_group_name
  remote_virtual_network_id    = local.vnet_peerings.connectivity_hub_to_dmlz.remote_virtual_network_id
  use_remote_gateways          = local.vnet_peerings.connectivity_hub_to_dmlz.peer_use_remote_gateways
  allow_virtual_network_access = local.vnet_peerings.connectivity_hub_to_dmlz.allow_virtual_network_access
  allow_forwarded_traffic      = local.vnet_peerings.connectivity_hub_to_dmlz.allow-forwarded-traffic
  allow_gateway_transit        = local.vnet_peerings.connectivity_hub_to_dmlz.peer_allow_gateway_transit
  depends_on = [
    azurerm_virtual_network.dmlz-virtual-network,
    azurerm_subnet.dmlz-subnets
  ]
}

output "core_network_output" {
  value = {
    virtual_network_name                      = azurerm_virtual_network.dmlz-virtual-network.name
    virtual_network_id                        = azurerm_virtual_network.dmlz-virtual-network.id
    services_subnet_id                        = azurerm_subnet.dmlz-subnets["services"].id
    aci_network_profile_id                    = try(azurerm_network_profile.aci-network-profile[0].id, "")
    connectivity_hub_vnet_resource_group_name = local.connectivity_hub_vnet_resource_group_name
    connectivity_hub_vnet_name                = local.connectivity_hub_vnet_name
    connectivity_hub_vnet_subscription_id     = local.connectivity_hub_vnet_subscription_id
  }
}

