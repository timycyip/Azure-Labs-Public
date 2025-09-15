# Create a random string for the suffix
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# Azure Front Door WAF Policy with custom rules
resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                              = "wafpolicy${random_string.suffix.result}"
  resource_group_name               = azurerm_resource_group.example.name
  sku_name                          = "Standard_AzureFrontDoor"
  enabled                           = true
  mode                              = "Prevention"
  redirect_url                      = "https://learn.microsoft.com/docs/"
  custom_block_response_status_code = 405
  custom_block_response_body        = base64encode("Blocked by Azure WAF")

  custom_rule {
    name     = "RateLimitRule1"
    priority = 100
    type     = "RateLimitRule"
    action   = "Block"
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    match_condition {
      match_variable = "RequestUri"
      operator       = "Contains"
      match_values   = ["/"]
    }
  }

  custom_rule {
    name     = "GeographicRule1"
    priority = 101
    type     = "MatchRule"
    action   = "Block"
    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      negation_condition = true
      match_values   = ["CA"]
    }
    # match_condition {
    #   match_variable = "RemoteAddr"
    #   operator       = "IPMatch"
    #   match_values   = ["10.10.10.0/24"]
    # }
  }

  # custom_rule {
  #   name     = "QueryStringSizeRule1"
  #   priority = 102
  #   type     = "MatchRule"
  #   action   = "Block"
  #   match_condition {
  #     match_variable = "RequestUri"
  #     operator       = "GreaterThan"
  #     match_values   = ["200"]
  #     transforms     = ["UrlDecode", "Trim", "Lowercase"]
  #   }
  # }

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Azure Front Door Security Policy to associate WAF with domains
resource "azurerm_cdn_frontdoor_security_policy" "waf_security_policy" {
  name                     = "waf-security-policy-${random_string.suffix.result}"
  cdn_frontdoor_profile_id = module.azurerm_cdn_frontdoor_profile.resource_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        # Associate with the default Front Door endpoint
        domain {
          cdn_frontdoor_domain_id = module.azurerm_cdn_frontdoor_profile.frontdoor_endpoints["ep1_key"].id
        }

        # Associate with the custom domain
        domain {
          cdn_frontdoor_domain_id = module.azurerm_cdn_frontdoor_profile.frontdoor_custom_domains["hello_domain"].id
        }

        patterns_to_match = ["/*"]
      }
    }
  }

}
