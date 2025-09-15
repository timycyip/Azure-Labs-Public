output "location" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.name
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.avm_res_web_site.resource_id
}

output "service_plan_id" {
  description = "The ID of the app service plan"
  value       = azurerm_service_plan.webapp.id
}

output "service_plan_name" {
  description = "Name of the service plan created"
  value       = azurerm_service_plan.webapp.name
}

output "sku_name" {
  description = "The SKU tier of the service plan"
  value       = azurerm_service_plan.webapp.sku_name
}

output "os_type" {
  description = "The OS type of the service plan"
  value       = azurerm_service_plan.webapp.os_type
}

output "worker_count" {
  description = "The number of workers in the service plan"
  value       = azurerm_service_plan.webapp.worker_count
}

output "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled for the service plan"
  value       = azurerm_service_plan.webapp.zone_balancing_enabled
}

output "web_app_url" {
  description = "The default hostname (endpoint) of the Web App."
  value       = "https://${module.avm_res_web_site.resource_uri}"
}

output "web_app_name" {
  description = "The name of the Azure Web App"
  value       = module.avm_res_web_site.name
}

# Azure Front Door outputs
output "frontdoor_profile_id" {
  description = "The ID of the Azure Front Door Profile"
  value       = module.azurerm_cdn_frontdoor_profile.resource_id
}

output "frontdoor_endpoint_hostname" {
  description = "The hostname of the Azure Front Door endpoint."
  value       = module.azurerm_cdn_frontdoor_profile.frontdoor_endpoints["ep1_key"].host_name
}

output "custom_domain_validation_token" {
  description = "The DNS validation token for your custom domain"
  value       = module.azurerm_cdn_frontdoor_profile.frontdoor_custom_domains["hello_domain"].validation_token
}

# Web App Identity Information
output "web_app_principal_id" {
  description = "Principal ID of the Web App's system-assigned managed identity"
  value       = module.avm_res_web_site.system_assigned_mi_principal_id
  sensitive   = true
}

output "current_user_principal_id" {
  description = "Object ID of the current user for RBAC assignments"
  value       = data.azurerm_client_config.current.object_id
  sensitive   = true
}
