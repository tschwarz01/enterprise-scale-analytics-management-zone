/*
locals {
  dockerImage    = "${var.devops_agent_params.container_name}:${var.devops_agent_params.container_tag}"
  dockerFilePath = "./scripts/DevOpsAgent"
  container_group = {
    count                       = var.devops_agent_params.devops_agent_instance_count
    name                        = "${var.common_module_params.resource_prefix}-agt"
    location                    = var.common_module_params.location
    resource_group_name         = "rg-${var.common_module_params.resource_prefix}-integration"
    ipAddressType               = "Private"
    osType                      = "Linux"
    networkProfileId            = var.devops_agent_params.aci_network_profile_id
    containerImage              = "${var.devops_agent_params.acr_login_server}/${var.devops_agent_params.container_name}:${var.devops_agent_params.container_tag}"
    countainer_cpu_count        = var.devops_agent_params.countainer_cpu_count
    countainer_memory           = var.devops_agent_params.countainer_memory
    containerPort               = 80
    containerPortProtocol       = "TCP"
    imageRegistryUsername       = var.devops_agent_params.acr_admin_username
    imageRegistryPassword       = var.devops_agent_params.acr_admin_password
    imageRegistryServer         = var.devops_agent_params.acr_login_server
    log_analytics_workspace_id  = var.devops_agent_params.log_analytics_workspace_id
    log_analytics_workspace_key = var.devops_agent_params.log_analytics_workspace_key
  }
}
*/
