# Web App Resources for Python Flask Application
# Cost-optimized configuration using AVM modules for Web App hosting

# Azure Service Plan for Web App (Free/B1 tier for demo purposes)
resource "azurerm_service_plan" "webapp" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Linux"  # Linux required for Python runtime
  resource_group_name = azurerm_resource_group.example.name
  # Use F1 (Free) tier for cost optimization (demo purposes)
  sku_name = "F1"
  tags     = local.tags
}

# Log Analytics Workspace for Application Insights (retained for observability)
resource "azurerm_log_analytics_workspace" "webapp" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.example.name
  # Reduced retention days for cost optimization
  retention_in_days = 30
  sku               = "PerGB2018"
  tags              = local.tags
}

# Azure Verified Module - Web App for Python Flask
module "avm_res_web_site" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.19"

  kind     = "webapp"
  location = azurerm_resource_group.example.location
  # Unique name for the web app
  name = "${module.naming.app_service.name_unique}-webapp"

  # Uses our cost-optimized service plan
  os_type                  = azurerm_service_plan.webapp.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.webapp.id
  
  # Required by org policy
  https_only = true

  # Python Flask-specific site configuration
  site_config = {
    application_stack = {
      "python" = {
        python_version = "3.12"  # Python 3.12 for modern compatibility
      }
    }
    # Health check for better app stability
    health_check_path = "/"
    health_check_eviction_time_in_min = 2
    # HTTPS only for security
    # https_only = true
    # Always on disabled for F1 tier (not supported)
    always_on = false
    # Minimal instances for cost control
    minimum_tls_version = 1.2
    # F1 free sku does not support 64 bit worker
    use_32_bit_worker = true
  }

  # Application Insights integration for monitoring (optional for demo)
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.webapp.id
  }

  # App settings for Flask configuration
  app_settings = {
    # Standard Flask environment settings
    FLASK_APP      = "app.py"
    FLASK_ENV      = "production"
    FLASK_DEBUG    = "False"
    FLASK_RUN_HOST = "0.0.0.0"
    FLASK_RUN_PORT = "8000"

    # Python-specific settings
    PYTHONPATH = "/home/site/wwwroot"
    # WSGI for production deployment
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }

  # Identity configuration for secure access (optional for demo)
  managed_identities = {
    system_assigned = true
  }

  # Enable telemetry for the module (can be disabled if not needed)
  enable_telemetry = var.enable_telemetry

  # Consistent tagging across the landing zone
  tags = local.tags
}
