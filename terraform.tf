terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
  backend "azurerm" {
    subscription_id      = "47f7e6d7-0e52-4394-92cb-5f106bbc647f"
    tenant_id            = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    resource_group_name  = "rg-data-management-zone-terraform"
    storage_account_name = "stgdatamgmtzoneterraform"
    container_name       = "tfescalemgmt2"
    key                  = "tfescalemgmt.tfstate"
    #use_azuread_auth     = true
  }
}
