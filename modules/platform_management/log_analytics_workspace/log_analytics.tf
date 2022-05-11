resource "azurerm_resource_group" "management-resource-group" {
  name     = var.common_module_params.resource_groups.management_resource_group
  location = var.common_module_params.location
}

resource "azurerm_automation_account" "mgmt-automation-acct" {
  depends_on = [
    azurerm_resource_group.management-resource-group
  ]
  location            = var.common_module_params.location
  name                = var.management_module_params.automation_account_name
  resource_group_name = azurerm_resource_group.management-resource-group.name
  sku_name            = "Basic"
}


resource "azurerm_log_analytics_workspace" "logmgmt-log-analytics-ws" {
  depends_on = [
    azurerm_resource_group.management-resource-group
  ]
  location            = var.common_module_params.location
  name                = var.management_module_params.log_analytics_workspace_name
  sku                 = var.management_module_params.log_analytics_sku
  retention_in_days   = var.management_module_params.log_analytics_log_retention_days
  resource_group_name = azurerm_resource_group.management-resource-group.name
}

resource "azurerm_log_analytics_linked_service" "logmgmt-log-analytics-automation-linked-service" {
  depends_on = [
    azurerm_log_analytics_workspace.logmgmt-log-analytics-ws,
    azurerm_automation_account.mgmt-automation-acct
  ]
  resource_group_name = azurerm_resource_group.management-resource-group.name
  workspace_id        = azurerm_log_analytics_workspace.logmgmt-log-analytics-ws.id
  read_access_id      = azurerm_automation_account.mgmt-automation-acct.id
}

output "log_analytics_module_output" {
  value = {
    log_analytics_name          = "${azurerm_log_analytics_workspace.logmgmt-log-analytics-ws.name}"
    logAnalyticsId              = "${azurerm_log_analytics_workspace.logmgmt-log-analytics-ws.id}"
    log_analytics_workspace_id  = "${azurerm_log_analytics_workspace.logmgmt-log-analytics-ws.workspace_id}"
    log_analytics_workspace_key = "${azurerm_log_analytics_workspace.logmgmt-log-analytics-ws.primary_shared_key}"
  }
}

data "azurerm_policy_definition" "example" {
  name = "2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
}

data "azurerm_subscription" "primary" {
}

/*
resource "azurerm_subscription_policy_assignment" "azPolicyActivityLog" {
  name                 = "2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
  subscription_id      = "/subscriptions/${var.common_module_params.subscriptionId}"
  policy_definition_id = data.azurerm_policy_definition.example.id
  description          = "Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace to monitor subscription-level events"
  display_name         = "Configure Azure Activity logs to stream to specified Log Analytics workspace"
  location             = "southcentral us"
  parameters           = <<PARAMS
    {
      "logAnalytics": {"value": "/subscriptions/47f7e6d7-0e52-4394-92cb-5f106bbc647f/resourcegroups/rg-esdmlz-dev-logging-and-management/providers/microsoft.operationalinsights/workspaces/esdmlz-dev-logws"}
    }
PARAMS
  identity { type = "SystemAssigned" }
}
#"logAnalytics": {"value": "esdmlz-dev-logws"}
#"logAnalytics": {"value": "/subscriptions/47f7e6d7-0e52-4394-92cb-5f106bbc647f/resourceGroups/rg-esdmlz-dev-logging-and-management/providers/Microsoft.OperationalInsights/workspaces/esdmlz-dev-logw"}

resource "azurerm_role_assignment" "policyRoleAssignment001" {
  scope              = "/subscriptions/${var.common_module_params.subscriptionId}"
  role_definition_id = "/subscriptions/${var.common_module_params.subscriptionId}/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
  principal_id       = azurerm_subscription_policy_assignment.azPolicyActivityLog.identity[0].principal_id
  depends_on         = [azurerm_subscription_policy_assignment.azPolicyActivityLog]
}

resource "azurerm_role_assignment" "policyRoleAssignment002" {
  scope              = "/subscriptions/${var.common_module_params.subscriptionId}"
  role_definition_id = "/subscriptions/${var.common_module_params.subscriptionId}/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa"
  principal_id       = azurerm_subscription_policy_assignment.azPolicyActivityLog.identity[0].principal_id
  depends_on         = [azurerm_subscription_policy_assignment.azPolicyActivityLog]
}

resource "azurerm_subscription_policy_remediation" "policyRemediation001" {
  name                    = "activitylogsremediation"
  subscription_id         = "/subscriptions/${var.common_module_params.subscriptionId}"
  policy_assignment_id    = azurerm_subscription_policy_assignment.azPolicyActivityLog.id
  resource_discovery_mode = "ReEvaluateCompliance"
  depends_on = [
    azurerm_log_analytics_workspace.logmgmt-log-analytics-ws,
    azurerm_log_analytics_linked_service.logmgmt-log-analytics-automation-linked-service,
    azurerm_subscription_policy_assignment.azPolicyActivityLog,
    azurerm_role_assignment.policyRoleAssignment001,
    azurerm_role_assignment.policyRoleAssignment002
  ]
}
*/
