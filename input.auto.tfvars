// Feature Flags (primarily for debugging)
#deployAzureFirewall = false
peer_with_connectivity_hub            = true
deploy_aci_hosted_azure_devops_agents = true
deploy_cicd_iaas_agents_subnet        = true
deploy_azure_data_factory             = true
deploy_adf_self_hosted_runtime        = true


####################################################
## NETWORK & CONNECTIVITY PARAMETERS
####################################################
// Network Settings

vnet_address_prefix                  = ["10.50.0.0/21"]
azure_firewall_subnet_address_prefix = "10.50.0.0/26"
gateway_subnet_address_prefix        = "10.50.0.64/26"
cicd_subnet_address_prefix           = "10.50.0.128/26"
aci_subnet_address_prefix            = "10.50.0.192/26"
services_subnet_address_prefix       = "10.50.1.0/24"

// Private DNS Zone Settings
use_existing_private_dns_zones_from_remote_subscription = false
existing_private_dns_zone_resource_group_name           = "pwrn-rg-network"

privatelink_dns_zone_names = [

  #"privatelink.azure-automation.net",
  "privatelink.database.windows.net",
  "privatelink.sql.azuresynapse.net",
  "privatelink.dev.azuresynapse.net",
  "privatelink.azuresynapse.net",
  "privatelink.blob.core.windows.net",
  "privatelink.queue.core.windows.net",
  "privatelink.dfs.core.windows.net",
  "privatelink.documents.azure.com",
  "privatelink.vaultcore.azure.net",
  "privatelink.azurecr.io",
  "privatelink.azconfig.io",
  "privatelink.servicebus.windows.net",
  "privatelink.datafactory.azure.net",
  "privatelink.adf.azure.com",
  "privatelink.purview.azure.com",
  "privatelink.purviewstudio.azure.com"
  #"privatelink.table.core.windows.net",
  #"privatelink.file.core.windows.net",
  #"privatelink.web.core.windows.net",
  #"privatelink.mongo.cosmos.azure.com",
  #"privatelink.cassandra.cosmos.azure.com",
  #"privatelink.gremlin.cosmos.azure.com",
  #"privatelink.table.cosmos.azure.com",
  #"privatelink.centralus.batch.azure.com",
  #"privatelink.eastus2.batch.azure.com",
  #"privatelink.southcentralus.batch.azure.com",
  #"privatelink.postgres.database.azure.com",
  #"privatelink.mysql.database.azure.com",
  #"privatelink.mariadb.database.azure.com",
  #"privatelink.managedhsm.azure.net",
  #"privatelink.centralus.azmk8s.io",
  #"privatelink.eastus2.azmk8s.io",
  #"privatelink.southcentralus.azmk8s.io",
  #"privatelink.search.windows.net",
  #"privatelink.centralus.backup.windowsazure.com",
  #"privatelink.eastus2.backup.windowsazure.com",
  #"privatelink.southcentralus.backup.windowsazure.com",
  #"privatelink.siterecovery.windowsazure.com",
  #"privatelink.azure-devices.net",
  #"privatelink.eventgrid.azure.net",
  #"privatelink.azurewebsites.net",
  #"privatelink.api.azureml.ms",
  #"privatelink.notebooks.azure.net",
  #"privatelink.service.signalr.net",
  #"privatelink.monitor.azure.com",
  #"privatelink.oms.opinsights.azure.com",
  #"privatelink.ods.opinsights.azure.com",
  #"privatelink.agentsvc.azure-automation.net",
  #"privatelink.cognitiveservices.azure.com",
  #"privatelink.afs.azure.net",
  #"privatelink.redis.cache.windows.net",
  #"privatelink.redisenterprise.cache.azure.net",
  #"privatelink.digitaltwins.azure.net",
  #"privatelink.azurehdinsight.net",
  #"privatelink.his.arc.azure.com",
  #"privatelink.guestconfiguration.azure.com",
  #"privatelink.media.azure.net"
]


####################################################
## PLATFORM MANAGEMENT LANDING ZONE PARAMETERS
####################################################


// Log Analytics Workspace Settings
log_analytics_log_retention_days = 50
log_analytics_sku                = "PerGB2018"

// Log Analytics Solutions Settings
enableSecuritySolution = false
enableAgentHealth      = true
enableChangeTracking   = true
enableUpdateMgmt       = true
enableActivityLog      = true
enableVmInsights       = true
enableServiceMap       = true
enableSqlAssessment    = true



##################################################
## CONSUMPTION MODULE PARAMETERS
##################################################
container_registry_sku                       = "Premium"
container_registry_public_network_enabled    = true
container_registry_quarantine_policy_enabled = false
devops_agent_dockerfile_path                 = "./scripts/DevOpsAgent"

##################################################
## INTEGRATION MODULE PARAMETERS
##################################################
adf_self_hosted_runtime_vmss_instance_count = 2
adf_self_hosted_runtime_vmss_sku            = "Standard_D2_v4"
devops_agent_instance_count                 = 2


##################################################
## SENSITIVE
##################################################
#adf_self_hosted_runtime_admin_username =
#adf_self_hosted_runtime_admin_password =
#devops_pat_token                          =
#azure_devops_organization_name                  =
#sp_client_id                                   =
#sp_client_secret                               =
#ado_agent_container_name                        =
#ado_agent_container_tag                         =
#connectivity_hub_virtual_network_id =
