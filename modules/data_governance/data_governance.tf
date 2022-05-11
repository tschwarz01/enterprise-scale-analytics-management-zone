// Resource Group
resource "azurerm_resource_group" "data-governance-resource-group" {
  name     = "rg-${var.common_module_params.resource_prefix}-data-governance"
  location = var.common_module_params.location
}

// Key Vault
resource "azurerm_key_vault" "keyVault" {
  name                            = local.purviewKeyVaultServiceParameters.name
  location                        = local.purviewKeyVaultServiceParameters.location
  resource_group_name             = local.purviewKeyVaultServiceParameters.resource_group_name
  tenant_id                       = local.purviewKeyVaultServiceParameters.tenantId
  soft_delete_retention_days      = local.purviewKeyVaultServiceParameters.softDeleteRetentionDays
  enabled_for_disk_encryption     = local.purviewKeyVaultServiceParameters.enabledForDiskEncryption
  purge_protection_enabled        = local.purviewKeyVaultServiceParameters.purgeProtectionEnabled
  enabled_for_template_deployment = local.purviewKeyVaultServiceParameters.enabledForTemplateDeployment
  enabled_for_deployment          = local.purviewKeyVaultServiceParameters.enabledForDeployment
  enable_rbac_authorization       = local.purviewKeyVaultServiceParameters.enableRbacAuthorization
  sku_name                        = local.purviewKeyVaultServiceParameters.skuName
  network_acls {
    bypass         = local.purviewKeyVaultServiceParameters.networkAclsBypass
    default_action = local.purviewKeyVaultServiceParameters.networkAclsDefaultAction
  }
}

// Purview
resource "azurerm_purview_account" "purviewAcct" {
  name                        = local.purviewServiceParameters.name
  resource_group_name         = local.purviewServiceParameters.resource_group_name
  location                    = local.purviewServiceParameters.location
  public_network_enabled      = local.purviewServiceParameters.publicNetworkEnabled
  managed_resource_group_name = local.purviewServiceParameters.managedresource_group_name

  identity {
    type = "SystemAssigned"
  }
}


// Role assignment
resource "azurerm_role_assignment" "purviewKeyvaultRoleAssignment" {
  scope                = azurerm_key_vault.keyVault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_purview_account.purviewAcct.identity[0].principal_id
  depends_on = [
    azurerm_purview_account.purviewAcct,
    azurerm_key_vault.keyVault
  ]
}

// Private Endpoints
resource "azurerm_private_endpoint" "privateEndpoint" {
  for_each            = local.privateEndpointMap
  name                = each.value["name"]
  location            = var.common_module_params.location
  resource_group_name = azurerm_resource_group.data-governance-resource-group.name
  subnet_id           = var.data_governance_module_params.private_endpoint_subnet_id

  private_service_connection {
    name                           = each.value["peServiceConnectionName"]
    private_connection_resource_id = each.value["peServiceConnectionResourceId"]
    subresource_names              = each.value["peSubresourceNames"]
    is_manual_connection           = each.value["peIsManualConnection"]
  }

  private_dns_zone_group {
    name                 = "ZoneGroup"
    private_dns_zone_ids = each.value["private_dns_zone_ids"]
  }
  depends_on = [
    azurerm_key_vault.keyVault,
    azurerm_purview_account.purviewAcct
  ]
}

// output
output "purviewOutput" {
  value = {
    purviewAcctId           = azurerm_purview_account.purviewAcct.id
    purviewCatalogEndpoint  = azurerm_purview_account.purviewAcct.catalog_endpoint
    purviewGuardianEndpoint = azurerm_purview_account.purviewAcct.guardian_endpoint
    purviewScanEndpoint     = azurerm_purview_account.purviewAcct.scan_endpoint
    purviewManagedResource  = azurerm_purview_account.purviewAcct.managed_resources
  }
}




