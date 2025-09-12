# App Service Resources
# Azure Landing Zone Application - Compute and Application Resources
#
# This file contains Azure App Service, Function App, and related compute resources
# for the application landing zone.

# App Service Plan for Function App
# FC1 (Flex Consumption) plan selected for lowest cost hello world deployment
resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "FC1"
  tags                = local.tags
}

# Azure Verified Module - Function App with Flex Consumption
# This uses the verified, Microsoft-maintained module for Function Apps
# AVM provides enterprise-grade, production-ready Terraform modules
module "avm_res_web_site" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.19.1"

  kind     = "functionapp"
  location = azurerm_resource_group.example.location
  name     = "${module.naming.function_app.name_unique}-flex"

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id

  enable_telemetry = var.enable_telemetry

  # Flex Consumption Plan configuration
  fc1_runtime_name      = "python"
  fc1_runtime_version   = "3.12"
  function_app_uses_fc1 = true

  # CONFIGURATION FOR HELLO WORLD
  # Optimized for minimal cost while maintaining functionality
  instance_memory_in_mb  = 512  # Minimum allowed memory for FC1
  maximum_instance_count = 40   # ✅ MINIMUM range: 40-1000 (Azure requirement)

  # Azure Policy required by the org
  https_only = true
  
  # Identity configuration for secure access
  managed_identities = {
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.user.id
    ]
  }

  # Storage account configuration with User Assigned Identity
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  storage_authentication_type       = "UserAssignedIdentity"
  storage_container_endpoint        = azurerm_storage_container.example.id
  storage_container_type            = "blobContainer"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.user.id

  # Consistent tagging across the Azure Landing Zone
  tags = local.tags
}
