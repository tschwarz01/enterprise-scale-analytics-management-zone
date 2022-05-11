resource "azurerm_data_factory_integration_runtime_self_hosted" "selfHostedIntegrationRuntime" {
  name            = local.selfHostedRuntime.name
  data_factory_id = var.adf_shir_module_params.dataFactoryId
}


resource "azurerm_windows_virtual_machine_scale_set" "dataFactoryShirVmss" {
  name                = local.adfShirVmss.name
  resource_group_name = local.adfShirVmss.resource_group_name
  location            = local.adfShirVmss.location
  sku                 = local.adfShirVmss.vmssSku
  instances           = local.adfShirVmss.instanceCount
  admin_password      = local.adfShirVmss.vmssAdminPassword
  admin_username      = local.adfShirVmss.vmssAdminUsername

  source_image_reference {
    publisher = local.adfShirVmss.sourceImage.publisher
    offer     = local.adfShirVmss.sourceImage.offer
    sku       = local.adfShirVmss.sourceImage.sku
    version   = local.adfShirVmss.sourceImage.version
  }

  os_disk {
    storage_account_type = local.adfShirVmss.osDisk.storageAccountType
    caching              = local.adfShirVmss.osDisk.caching
  }

  network_interface {
    name    = local.adfShirVmss.networkInterface.name
    primary = local.adfShirVmss.networkInterface.primary

    ip_configuration {
      name      = local.adfShirVmss.ipconfig.name
      primary   = local.adfShirVmss.ipconfig.primary
      subnet_id = local.adfShirVmss.ipconfig.subnetId
    }
  }

  extension {
    name                 = "${var.common_module_params.resource_prefix}-vmss-extension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    settings             = <<SETTINGS
        {
            "fileUris": [
                "https://raw.githubusercontent.com/Azure/data-landing-zone/main/code/installSHIRGateway.ps1"
                ]
        }
    SETTINGS
    protected_settings   = <<PROTECTED_SETTINGS
      {
          "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File installSHIRGateway.ps1 -gatewayKey ${azurerm_data_factory_integration_runtime_self_hosted.selfHostedIntegrationRuntime.primary_authorization_key}"
      }
  PROTECTED_SETTINGS
  }

}
