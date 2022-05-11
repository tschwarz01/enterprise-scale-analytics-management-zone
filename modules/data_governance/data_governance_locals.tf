locals {
  purviewKeyVaultServiceParameters = {
    name                         = "${var.common_module_params.resource_prefix}-purview-kv2"
    location                     = var.common_module_params.location
    resource_group_name          = azurerm_resource_group.data-governance-resource-group.name
    tenantId                     = var.common_module_params.tenantId
    softDeleteRetentionDays      = 7
    enabledForDiskEncryption     = false
    purgeProtectionEnabled       = true
    enabledForTemplateDeployment = false
    enabledForDeployment         = false
    enableRbacAuthorization      = true
    skuName                      = "standard"
    networkAclsBypass            = "AzureServices"
    networkAclsDefaultAction     = "Deny"
    private_endpoint_subnet_id   = var.data_governance_module_params.private_endpoint_subnet_id
  }
}

locals {
  purviewServiceParameters = {
    name                       = "${var.common_module_params.resource_prefix}-purview-acct"
    resource_group_name        = azurerm_resource_group.data-governance-resource-group.name
    location                   = var.common_module_params.location
    publicNetworkEnabled       = true
    managedresource_group_name = "rg-${var.common_module_params.resource_prefix}-purview-managed"
  }
}


locals {
  privateEndpointMap = {
    purviewKeyVaultPrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-kv-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-kv-pe-sc"
      peServiceConnectionResourceId = azurerm_key_vault.keyVault.id
      peSubresourceNames            = ["vault"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.keyvault_private_dns_zone_id]
    }
    purviewAccountPrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-acct-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-acct-pe-sc"
      peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.id
      peSubresourceNames            = ["account"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.purview_account_private_dns_zone_id]
    }
    purviewPortalPrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-portal-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-portal-pe-sc"
      peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.id
      peSubresourceNames            = ["portal"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.purview_portal_private_dns_zone_id]
    }
    purviewBlobPrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-blob-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-blob-pe-sc"
      peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.managed_resources[0].storage_account_id
      peSubresourceNames            = ["blob"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.purview_blob_private_dns_zone_id]
    }
    purviewQueuePrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-queue-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-queue-pe-sc"
      peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.managed_resources[0].storage_account_id
      peSubresourceNames            = ["queue"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.purview_queue_private_dns_zone_id]
    }
    purviewEventHubPrivateEndpoint = {
      name                          = "${var.common_module_params.resource_prefix}-purview-eh-pe"
      location                      = var.common_module_params.location
      resource_group_name           = azurerm_resource_group.data-governance-resource-group.name
      subnet_id                     = var.data_governance_module_params.private_endpoint_subnet_id
      peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-eh-pe-sc"
      peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.managed_resources[0].event_hub_namespace_id
      peSubresourceNames            = ["namespace"]
      peIsManualConnection          = false
      private_dns_zone_ids          = [var.data_governance_module_params.purview_event_hub_private_dns_zone_id]
    }
  }
}



/*
locals {
  purviewKeyVaultPrivateEndpointServiceParams = {
    peName                        = "${var.common_module_params.resource_prefix}-purview-kv-pe"
    peLocation                    = var.common_module_params.location
    peResourceGroup               = azurerm_resource_group.data-governance-resource-group.name
    peSubnetId                    = var.data_governance_module_params.private_endpoint_subnet_id
    peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-kv-pe-sc"
    peServiceConnectionResourceId = azurerm_key_vault.keyVault.id
    peSubresourceNames            = "vault"
    peIsManualConnection          = false
    dnsZoneId                     = var.data_governance_module_params.keyvault_private_dns_zone_id
  }
}

locals {
  purviewAccountPrivateEndpointServiceParams = {
    peName                        = "${var.common_module_params.resource_prefix}-purview-acct-pe"
    peLocation                    = var.common_module_params.location
    peResourceGroup               = azurerm_resource_group.data-governance-resource-group.name
    peSubnetId                    = var.data_governance_module_params.private_endpoint_subnet_id
    peServiceConnectionName       = "${var.common_module_params.resource_prefix}-purview-acct-pe-sc"
    peServiceConnectionResourceId = azurerm_purview_account.purviewAcct.id
    peSubresourceNames            = "account"
    peIsManualConnection          = false
    dnsZoneId                     = var.data_governance_module_params.keyvault_private_dns_zone_id
  }
}
*/
