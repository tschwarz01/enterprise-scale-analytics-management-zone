resource "azurerm_resource_group" "consumption-resource-group" {
  name     = "rg-${var.common_module_params.resource_prefix}-consumption"
  location = var.common_module_params.location
}

resource "azurerm_container_registry" "acr" {
  name                          = replace("${var.common_module_params.resource_prefix}-acr", "-", "")
  resource_group_name           = azurerm_resource_group.consumption-resource-group.name
  location                      = var.common_module_params.location
  sku                           = var.consumption_module_params.acr_sku
  public_network_access_enabled = var.consumption_module_params.acr_public_network_enabled
  quarantine_policy_enabled     = var.consumption_module_params.acr_quarantine_enabled
  admin_enabled                 = true
  identity {
    type = "SystemAssigned"
  }
  retention_policy = [{
    days    = 7
    enabled = true
  }]
  trust_policy = [{
    enabled = false
  }]
}

resource "azurerm_private_endpoint" "acrPrivateEndpoint" {
  name                = "${var.common_module_params.resource_prefix}-acr-pe"
  location            = var.common_module_params.location
  resource_group_name = azurerm_resource_group.consumption-resource-group.name
  subnet_id           = var.consumption_module_params.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_container_registry.acr.name}-acr-pe-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "ZoneGroup"
    private_dns_zone_ids = [var.consumption_module_params.container_registry_private_dns_zone_id]
  }
  depends_on = [
    azurerm_container_registry.acr
  ]
}

resource "azurerm_shared_image_gallery" "sharedImageGallery" {
  name                = replace("${var.common_module_params.resource_prefix}-shared-image-gallery", "-", "_")
  resource_group_name = azurerm_resource_group.consumption-resource-group.name
  location            = var.common_module_params.location

  tags = var.common_module_params.tags
}

resource "null_resource" "docker_push01" {
  count = var.devops_agent_params.deploy_aci_hosted_azure_devops_agents ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
        az acr login -n ${var.devops_agent_params.acr_login_server} -u ${var.devops_agent_params.sp_client_id} -p ${var.devops_agent_params.sp_client_secret} && az acr build --registry ${var.devops_agent_params.containerRegistryName} --image ${var.devops_agent_params.docker_image} ${var.devops_agent_params.devops_agent_dockerfile_path}
      EOT
  }
}

output "consumption_module_output" {
  value = {
    acr_login_server   = azurerm_container_registry.acr.login_server
    acrName            = azurerm_container_registry.acr.name
    acr_admin_username = azurerm_container_registry.acr.admin_username
    acr_admin_password = azurerm_container_registry.acr.admin_password

  }
}

output "docker_results" {
  value = null_resource.docker_push01
}
