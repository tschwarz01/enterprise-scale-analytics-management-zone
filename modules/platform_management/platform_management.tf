module "deploy-log-analytics-workspace" {
  source                   = "./log_analytics_workspace"
  management_module_params = var.management_module_params
  common_module_params     = var.common_module_params

}

output "log_analytics_module_output" {
  value = module.deploy-log-analytics-workspace.log_analytics_module_output
}
