/*
provider "azurerm" {
  features {}

  subscription_id = <replace>
  tenant_id       = <replace>
  client_id       = <replace>
  client_secret   = <replace>
}

// If using existing Private DNS Zones in a remote subscription,
// you must manually update the subscription ID below to refer to the subscription in which the DNS Zones are hosted
provider "azurerm" {
  subscription_id = <replace> // <-  MUST UPDATE VALUE
  client_id       = <replace>
  client_secret   = <replace>
  tenant_id       = <replace>
  alias           = "dnssub"
  features {}
}

// If peering the DMLZ Virtual Network with a Virtual Network in a Connectivity Hub subscription
// you must manually update the subscription ID below to refer to the remote subscription
provider "azurerm" {
  subscription_id = <replace> // <-  MUST UPDATE VALUE
  client_id       = <replace>
  client_secret   = <replace>
  tenant_id       = <replace>
  alias           = "hubsub"
  features {}
}
*/
