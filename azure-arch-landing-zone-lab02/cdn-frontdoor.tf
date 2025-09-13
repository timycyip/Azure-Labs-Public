# module "avm-res-cdn-profile_example_afd_private_link_to_Linux_WebApp" {
#   source  = "Azure/avm-res-cdn-profile/azurerm//examples/afd_private_link_to_Linux_WebApp"
#   version = "0.1.9"
# }

# Service Plan and Web App resources removed - using Function App from app-service.tf

# This is the module call
module "azurerm_cdn_frontdoor_profile" {
  source  = "Azure/avm-res-cdn-profile/azurerm"
  version = "~> 0.1.9"

  location            = azurerm_resource_group.example.location
  name                = module.naming.cdn_profile.name_unique
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard_AzureFrontDoor"  # Cost-effective Standard SKU
  enable_telemetry    = var.enable_telemetry
  front_door_endpoints = {
    ep1_key = {
      name = "ep1-${module.naming.cdn_endpoint.name_unique}"
      tags = {
        environment = "avm-demo"
      }
    }
  }
  front_door_origin_groups = {
    og1_key = {
      name = "og-functionapp"
      health_probe = {
        hp1 = {
          interval_in_seconds = 100
          path                = "/api/healthcheck"  # Suitable for Function Apps
          protocol            = "Https"
          request_type        = "HEAD"
        }
      }
      load_balancing = {
        lb1 = {
          additional_latency_in_milliseconds = 0
          sample_size                        = 16
          successful_samples_required        = 3
        }
      }
    }
  }
  front_door_origins = {
    origin1_key = {
      name                           = "origin-functionapp"
      origin_group_key               = "og1_key"
      enabled                        = true
      certificate_name_check_enabled = true
      host_name                      = module.avm_res_web_site.resource_uri
      http_port                      = 80
      https_port                     = 443
      host_header                    = module.avm_res_web_site.resource_uri
      priority                       = 1
      weight                         = 500
      # Private link to Function App requires most costly premium plan
      # private_link = {
      #   pl = {
      #     request_message        = "Please approve this private link connection"
      #     target_type            = "sites"
      #     location               = azurerm_resource_group.example.location
      #     private_link_target_id = module.avm_res_web_site.resource_id
      #   }
      # }
    }
  }
  front_door_routes = {
    route1_key = {
      name                   = "route1"
      endpoint_key           = "ep1_key"
      origin_group_key       = "og1_key"
      origin_keys            = ["origin1_key"]
      forwarding_protocol    = "HttpsOnly"
      https_redirect_enabled = true
      patterns_to_match      = ["/*"]
      supported_protocols    = ["Http", "Https"]
    }
  }
}
