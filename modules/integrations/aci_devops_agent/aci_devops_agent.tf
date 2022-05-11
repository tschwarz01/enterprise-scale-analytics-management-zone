


resource "azurerm_container_group" "linux-container-group" {
  #depends_on          = [null_resource.docker_push01]
  count               = var.devops_agent_params.devops_agent_instance_count
  name                = "ado-agent-group-001"
  location            = var.common_module_params.location
  resource_group_name = var.common_module_params.resource_groups.integration_resource_group
  ip_address_type     = "Private"
  os_type             = "Linux"
  network_profile_id  = var.devops_agent_params.aci_network_profile_id

  container {
    name   = "ado-agent-instance-${count.index + 2}"
    image  = "${var.devops_agent_params.acr_login_server}/${var.devops_agent_params.container_name}:${var.devops_agent_params.container_tag}"
    cpu    = var.devops_agent_params.countainer_cpu_count
    memory = var.devops_agent_params.container_memory

    # this field seems to be mandatory (error happens if not there). See https://github.com/terraform-providers/terraform-provider-azurerm/issues/1697#issuecomment-608669422
    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      AZP_URL        = "https://dev.azure.com/${var.devops_agent_params.devops_organization_name}"
      AZP_POOL       = var.devops_agent_params.devops_agent_pool_name
      AZP_AGENT_NAME = "aci-agent-${count.index}"
    }

    secure_environment_variables = {
      AZP_TOKEN = var.devops_agent_params.devops_pat_token
    }
  }

  image_registry_credential {
    username = var.devops_agent_params.acr_admin_username
    password = var.devops_agent_params.acr_admin_password
    server   = var.devops_agent_params.acr_login_server
  }

  diagnostics {
    log_analytics {
      log_type      = "ContainerInsights"
      workspace_id  = var.devops_agent_params.log_analytics_workspace_id
      workspace_key = var.devops_agent_params.log_analytics_workspace_key
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

output "aciDevOpsOutput" {
  value = azurerm_container_group.linux-container-group
}


/*
resource "azurerm_container_registry_agent_pool" "acrRegistryPool" {
  name                      = "${var.common_module_params.resource_prefix}-agentPool"
  resource_group_name       = "rg-${var.common_module_params.resource_prefix}-consumption"
  location                  = var.common_module_params.location
  container_registry_name   = "esdmlzdevacr"
  instance_count            = 2
  tier                      = "S1"
  virtual_network_subnet_id = var.integration_module_params.private_endpoint_subnet_id
}
*/
