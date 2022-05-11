locals {
  adfShirVmss = {
    name                = "adf-shir"
    location            = var.common_module_params.location
    vmssSku             = var.adf_shir_module_params.adf_shir_vmss_sku
    instanceCount       = var.adf_shir_module_params.adf_shir_vmss_instance_count
    vmssAdminUsername   = var.adf_shir_module_params.adf_shir_vmss_username
    vmssAdminPassword   = var.adf_shir_module_params.adf_shir_vmss_password
    resource_group_name = var.common_module_params.resource_groups.integration_resource_group
    sourceImage = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    osDisk = {
      storageAccountType = "Standard_LRS"
      caching            = "ReadWrite"
    }
    networkInterface = {
      name    = "${var.common_module_params.resource_prefix}-shir-nic"
      primary = true
    }
    ipconfig = {
      name     = "ipconfig-internal"
      primary  = true
      subnetId = var.adf_shir_module_params.adf_shir_subnet_id
    }

  }
  vmssExtension = {
    name               = "${var.common_module_params.resource_prefix}-vmss-extension"
    vmssId             = azurerm_windows_virtual_machine_scale_set.dataFactoryShirVmss.id
    publisher          = "Microsoft.Compute"
    type               = "CustomScriptExtension"
    typeHandlerVersion = "1.10"
    settings = jsonencode({
      "fileUris" : ["${var.adf_shir_module_params.adf_shir_install_script}"],
      "commandToExecute" : "powershell.exe -ExecutionPolicy Unrestricted -File installSHIRGateway.ps1 -gatewayKey ${azurerm_data_factory_integration_runtime_self_hosted.selfHostedIntegrationRuntime.primary_authorization_key}"
    })
  }
  selfHostedRuntime = {
    name = "${var.common_module_params.resource_prefix}-adf-shir"
  }

}
