variable "global_settings" {
  default = {
    passthrough    = false
    random_length  = 4
    default_region = "region1"
    regions = {
      region1 = "southcentralus"
      region2 = "centralus"
    }
  }
}

variable "resource_groups" {
  default = {}
}

variable "tenant_id" {
  type        = string
  description = "Azure Active Directory Tenant ID"
  default     = null
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dmlz"
}

variable "prefix" {
  type        = string
  description = "Specifies the prefix for all resources created in this deployment."
  default     = "dmz"

  validation {
    condition = (
      length(var.prefix) > 1 &&
      length(var.prefix) < 11
    )
    error_message = "The value for var: prefix must be between 2 and 10 characters in length."
  }
}

variable "location" {
  type        = string
  description = "Specifies the location for all resources."
  default     = "southcentralus"
}

variable "tags" {
  type        = map(string)
  description = "Specifies the tags that you want to apply to all resources."
  default = {
    "tagKey" = "tagValue"
  }
}

// NETWORKING VARIABLES
variable "peer_with_connectivity_hub" {
  type        = bool
  description = "Boolean flag which determines if the Enterprise Scale Data Management Landing Zone's virtual network should be peered to a virtual network in the Connectivity Platform Landing Zone."
  default     = true
}

variable "connectivity_hub_virtual_network_id" {
  type        = string
  description = "The resource id of the virtual network in the Connectivity Platform Landing Zone to which the Management Platform Landing Zone should be peered"
  default     = null
}

variable "deploy_aci_hosted_azure_devops_agents" {
  type        = bool
  description = "Deploy Azure Container Instance containers hosting the Azure DevOps Agent into a virtual network.  These agents may be shared across Enterprise Scale Data Landing Zones."
  default     = true
}

variable "deploy_cicd_iaas_agents_subnet" {
  type        = bool
  description = "True or False:  Deploy a subnet dedicated to CI/CD (Azure DevOps, GitHub Action Runners, etc) agents."
  default     = true
}

variable "deploy_azure_data_factory" {
  type        = bool
  description = "Deploy an empty instance of Azure Data Factory, which will have primary association with any Self-Hosted Integration Runtimes that will be shared amongst Enterprise Scale Data Landing Zones."
  default     = true
}

variable "deploy_adf_self_hosted_runtime" {
  type        = bool
  description = "Deploy VM Scale Set to be used as the Shared Self-Hosted Integration Runtimes by Data Factory instances deployed to Enterprise Scale Data Landing Zones."
  default     = true
}

variable "vnet_address_prefix" {
  type        = list(string)
  default     = ["10.0.0.0/21"]
  description = "Specifies the address space used by the Management Zone VNet"
}

variable "azure_firewall_subnet_address_prefix" {
  type        = string
  description = "Specifies the address space of the subnet that is used for Azure Firewall."
  default     = "10.0.0.0/24"
}

variable "services_subnet_address_prefix" {
  type        = string
  description = "Address space to use for the shared services subnet within the Management Zone VNet"
  default     = "10.0.1.0/24"
}

variable "cicd_subnet_address_prefix" {
  type        = string
  description = "Address space to use for CI/CD IaaS agents"
}

variable "gateway_subnet_address_prefix" {
  type        = string
  description = "Address space to use for the Virtual Network Gateway subnet within the Management Zone VNet"
  default     = "10.0.2.0/26"
}

variable "dp001_subnet_address_prefix" {
  type        = string
  description = "Address space to use for the first Data Product subnet within the Management Zone VNet"
  default     = "10.0.2.64/26"
}

variable "aci_subnet_address_prefix" {
  type        = string
  description = "Address space to use for the subnet which will be delagated to the Azure Container Instance service."
  default     = "10.0.4.0/24"
}

variable "use_existing_private_dns_zones_from_remote_subscription" {
  type        = bool
  description = "Determines if the resources created by this deployment will utilize pre-existing Private DNS Zones, located in a remote subscription (likely in the Connectivity Platform Landing Zone), for PrivateLink resources. This variable's value should only be true when the variable 'deploy_privatelink_dns_zones_in_dmlz' is set to false"
  default     = true
}

variable "existing_private_dns_zone_resource_group_name" {
  type        = string
  description = "Existing resource group where Azure Private DNS Zones are deployed.  This should be null if var: use_existing_private_dns_zones_from_remote_subscription = false."
}

variable "privatelink_dns_zone_names" {
  type        = list(string)
  description = "A list of Private DNS Zone names utilized by Azure Private Endpoints"
  default     = []
}


// PLATFORM MANAGEMENT LANDING ZONE VARIABLES


// LOG ANALYTICS WORKSPACE VARIABLES
variable "log_analytics_log_retention_days" {
  type        = number
  description = "The number of days to retain logged information within the Platform Management LZ Log Analytics Workspace."
  default     = 50
}

variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}

// LOG ANALYTICS SOLUTIONS VARIABLES
variable "enableSecuritySolution" {
  type        = bool
  description = "Enables the Log Analytics Security solution."
  default     = false
}
variable "enableAgentHealth" {
  type        = bool
  description = "Enables the Log Analytics Agent Health solution."
  default     = true
}
variable "enableChangeTracking" {
  type        = bool
  description = "Enables the Log Analytics Change Tracking solution."
  default     = true
}
variable "enableUpdateMgmt" {
  type        = bool
  description = "Enables the Log Analytics Update Management solution."
  default     = true
}
variable "enableActivityLog" {
  type        = bool
  description = "Enables the Log Analytics Activity Log solution."
  default     = true
}
variable "enableVmInsights" {
  type        = bool
  description = "Enables the Log Analytics VM Insights solution."
  default     = true
}
variable "enableServiceMap" {
  type        = bool
  description = "Enables the Log Analytics Service Map solution."
  default     = true
}
variable "enableSqlAssessment" {
  type        = bool
  description = "Enables the Log Analytics SQL Assessment solution."
  default     = true
}

// CONSUMPTION & INTEGRATION VARIABLES
variable "container_registry_sku" {
  type        = string
  description = "Designates the SKU to be used for Azure Container Registry"
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.container_registry_sku)
    error_message = "Valid values for var: container_registry_sku are (Basic, Standard, Premium)."
  }
}

variable "container_registry_public_network_enabled" {
  type        = bool
  description = "Designates whether public network access is allowed for Azure Container Registry"
  default     = false
}

variable "container_registry_quarantine_policy_enabled" {
  type        = bool
  description = "Designates whether quarantine policy is enabled for Azure Container Registry"
  default     = false
}

variable "adf_enable_public_network" {
  type        = bool
  description = "Designates whether users will be able to connect to Azure Data Factory studio when not on the local private network."
  default     = true
}

variable "adf_managed_virtual_network_enabled" {
  type        = bool
  description = "Use Azure Data Factory with an Azure managed virtual network."
  default     = true
}

variable "adf_shir_install_script_uri" {
  type        = string
  description = "URL containing the Azure Data Factory Self-Hosted Integration Runtime installation script."
  default     = "https://raw.githubusercontent.com/Azure/data-landing-zone/main/code/installSHIRGateway.ps1"
}

variable "adf_self_hosted_runtime_admin_password" {
  type    = string
  default = ""
}

variable "adf_self_hosted_runtime_admin_username" {
  type    = string
  default = "adminuser"
}

variable "adf_self_hosted_runtime_vmss_instance_count" {
  type    = number
  default = 2
}

variable "adf_self_hosted_runtime_vmss_sku" {
  type    = string
  default = "Standard_D2_v4"
}

variable "azure_devops_organization_name" {
  type = string
}

variable "azure_devops_devops_agent_pool_name" {
  type    = string
  default = "ACI_Pool"
}

variable "devops_pat_token" {
  type = string
}

variable "sp_client_id" {
  type = string
}

variable "sp_client_secret" {
  type = string
}

variable "ado_agent_container_name" {
  type = string
}

variable "ado_agent_container_tag" {
  type = string
}

variable "devops_agent_dockerfile_path" {
  type = string
}

variable "devops_agent_instance_count" {
  type        = number
  description = "The number of Azure Container Instances to use as Azure DevOps Agents."
  default     = 2
}

#######################################################

