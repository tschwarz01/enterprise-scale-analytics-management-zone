locals {
  resource_prefix = lower("${var.prefix}-${var.environment}")
  tagsDefault = {
    Owner       = "Enterprise Scale Analytics Scenario"
    Project     = "Enterprise Scale Analytics Scneario"
    Environment = var.environment
    Toolkit     = "Terraform"
  }
}



locals {
  common_module_params = {
    environment     = var.environment
    location        = var.location
    resource_prefix = lower("${var.prefix}-${var.environment}")
    tenantId        = data.azurerm_client_config.tfazconfig.tenant_id
    subscriptionId  = data.azurerm_client_config.tfazconfig.subscription_id
    tags            = merge(var.tags, local.tagsDefault)
    resource_groups = {
      network_resource_group            = "rg-${local.resource_prefix}-network"
      automation_resource_group         = "rg-${local.resource_prefix}-automation"
      management_resource_group         = "rg-${local.resource_prefix}-logging-and-management"
      dns_zone_resource_group           = "rg-${local.resource_prefix}-private-dns"
      data_governance_resource_group    = "rg-${local.resource_prefix}-data-governance"
      containers_resource_group         = "rg-${local.resource_prefix}-containers"
      consumption_resource_group        = "rg-${local.resource_prefix}-consumption"
      monitoring_resource_group         = "rg-${local.resource_prefix}-monitoring"
      integration_resource_group        = "rg-${local.resource_prefix}-integration"
      marketplace_resource_group        = "rg-${local.resource_prefix}-marketplace"
      service_layer_resource_group      = "rg-${local.resource_prefix}-service-layer"
      mesh_service_layer_resource_group = "rg-${local.resource_prefix}-mesh-service-layer"
      shared_services_resource_group    = "rg-${local.resource_prefix}-shared-services"
    }
  }
  network_module_params = {
    network_resource_group               = local.common_module_params.resource_groups.network_resource_group
    peer_with_connectivity_hub           = var.peer_with_connectivity_hub
    vnet_address_prefix                  = var.vnet_address_prefix
    azure_firewall_subnet_address_prefix = var.azure_firewall_subnet_address_prefix
    services_subnet_address_prefix       = var.services_subnet_address_prefix
    gateway_subnet_address_prefix        = var.gateway_subnet_address_prefix
    cicd_subnet_address_prefix           = var.cicd_subnet_address_prefix
    aci_subnet_address_prefix            = var.aci_subnet_address_prefix
    deploy_aci_subnet                    = var.deploy_aci_hosted_azure_devops_agents
    deploy_cicd_iaas_agents_subnet       = var.deploy_cicd_iaas_agents_subnet
    connectivity_hub_virtual_network_id  = var.connectivity_hub_virtual_network_id
  }
  private_dns_zone_module_params = {
    existing_private_dns_zone_resource_group_name = var.existing_private_dns_zone_resource_group_name
  }
  new_private_dns_zone_module_params = {
    dnsZones             = var.privatelink_dns_zone_names
    virtual_network_name = module.network-services-module.core_network_output.virtual_network_name
    virtual_network_id   = module.network-services-module.core_network_output.virtual_network_id
  }
  management_module_params = {
    log_analytics_workspace_name     = "${local.resource_prefix}-logws"
    log_analytics_sku                = var.log_analytics_sku
    log_analytics_log_retention_days = var.log_analytics_log_retention_days
    automation_account_name          = "${local.resource_prefix}-automation-acct"
  }
  data_governance_module_params = {
    private_endpoint_subnet_id            = module.network-services-module.core_network_output.services_subnet_id
    keyvault_private_dns_zone_id          = local.private_dns_zone_map["privatelink.vaultcore.azure.net"].id
    purview_account_private_dns_zone_id   = local.private_dns_zone_map["privatelink.purview.azure.com"].id
    purview_portal_private_dns_zone_id    = local.private_dns_zone_map["privatelink.purviewstudio.azure.com"].id
    purview_blob_private_dns_zone_id      = local.private_dns_zone_map["privatelink.blob.core.windows.net"].id
    purview_queue_private_dns_zone_id     = local.private_dns_zone_map["privatelink.queue.core.windows.net"].id
    purview_event_hub_private_dns_zone_id = local.private_dns_zone_map["privatelink.servicebus.windows.net"].id
  }
  consumption_module_params = {
    acr_sku                                = var.container_registry_sku
    acr_public_network_enabled             = var.container_registry_public_network_enabled
    acr_quarantine_enabled                 = var.container_registry_quarantine_policy_enabled
    private_endpoint_subnet_id             = module.network-services-module.core_network_output.services_subnet_id
    container_registry_private_dns_zone_id = local.private_dns_zone_map["privatelink.azurecr.io"].id
  }
  integration_module_params = {
    deploy_aci_hosted_azure_devops_agents = var.deploy_aci_hosted_azure_devops_agents
    deploy_adf                            = var.deploy_azure_data_factory
    deploy_adf_shir                       = var.deploy_adf_self_hosted_runtime
    adf_managed_virtual_network_enabled   = var.adf_managed_virtual_network_enabled
    adf_enable_public_network             = var.adf_enable_public_network
    private_endpoint_subnet_id            = module.network-services-module.core_network_output.services_subnet_id
    adf_factory_private_dns_zone_id       = local.private_dns_zone_map["privatelink.datafactory.azure.net"].id
    adf_portal_private_dns_zone_id        = local.private_dns_zone_map["privatelink.adf.azure.com"].id
  }
  adf_shir_module_params = {
    adf_shir_install_script      = var.adf_shir_install_script_uri
    adf_shir_subnet_id           = module.network-services-module.core_network_output.services_subnet_id
    adf_shir_vmss_sku            = var.adf_self_hosted_runtime_vmss_sku
    adf_shir_vmss_password       = var.adf_self_hosted_runtime_admin_password
    adf_shir_vmss_username       = var.adf_self_hosted_runtime_admin_username
    adf_shir_vmss_instance_count = var.adf_self_hosted_runtime_vmss_instance_count
  }
  devops_agent_params = {
    deploy_aci_hosted_azure_devops_agents = var.deploy_aci_hosted_azure_devops_agents
    devops_agent_instance_count           = var.devops_agent_instance_count
    acr_login_server                      = module.consumption-module.consumption_module_output.acr_login_server
    container_name                        = lower(var.ado_agent_container_name)
    container_tag                         = lower(var.ado_agent_container_tag)
    countainer_cpu_count                  = 2
    container_memory                      = 4
    docker_image                          = "${lower(var.ado_agent_container_name)}:${lower(var.ado_agent_container_tag)}"
    devops_agent_dockerfile_path          = var.devops_agent_dockerfile_path
    devops_pat_token                      = var.devops_pat_token
    devops_agent_pool_name                = var.azure_devops_devops_agent_pool_name
    sp_client_id                          = var.sp_client_id
    sp_client_secret                      = var.sp_client_secret
    containerRegistryName                 = module.consumption-module.consumption_module_output.acrName
    devops_organization_name              = var.azure_devops_organization_name
    acr_admin_password                    = module.consumption-module.consumption_module_output.acr_admin_password
    acr_admin_username                    = module.consumption-module.consumption_module_output.acr_admin_username
    log_analytics_workspace_id            = module.management-module.log_analytics_module_output.log_analytics_workspace_id
    log_analytics_workspace_key           = module.management-module.log_analytics_module_output.log_analytics_workspace_key
    aci_network_profile_id                = module.network-services-module.core_network_output.aci_network_profile_id
  }
}

locals {
  deploy_zone_results   = try(module.deploy-private-dns-zones[0].private-dns-zones, null)
  existing_zone_results = try(module.use-existing-private-dns-zones[0].private-dns-zones, null)
  zone_results          = coalesce(local.deploy_zone_results, local.existing_zone_results)
  private_dns_zone_map  = try({ for key, value in local.zone_results : key => { id = value.id } if length(regexall("privatelink", value.name)) > 0 }, { for key, value in local.zone_results.resources : value.name => { id = value.id } if length(regexall("privatelink", value.name)) > 0 })
  #new_dns_zone_map      = { for key, value in module.deploy-private-dns-zones[0].private-dns-zones : key => { id = value.id } if length(regexall("privatelink", value.name)) > 0 }
  #existing_dns_zone_map = try({ for key, value in module.use-existing-private-dns-zones[0].private-dns-zones : key => { id = value.id } if length(regexall("privatelink", value.name)) > 0 },null)
}

/*
locals {
  private_dns_zone_ids = coalesce(module.use-existing-private-dns-zones[0].private-dns-zones["privatelink.vaultcore.azure.net"].id, module.deploy-private-dns-zones[0].private-dns-zones["privatelink.vaultcore.azure.net"].id, "")
}
*/
