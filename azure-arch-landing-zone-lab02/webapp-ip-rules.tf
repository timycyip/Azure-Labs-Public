# Construct dynamic Cloudflare IP restriction rules
locals {
  # Static rules (Azure Front Door and Default Deny)
  static_ip_restrictions = {
    allow_frontdoor = {
      action      = "Allow"
      service_tag = "AzureFrontDoor.Backend"
      priority    = 100
      name        = "AllowFrontDoor"
    }
    deny_all = {
      action     = "Deny"
      ip_address = "0.0.0.0/0"
      priority   = 65000
      name       = "DenyAllOthers"
    }
  }

  # Dynamic Cloudflare IPv4 rules from data source
  cloudflare_ipv4_restrictions = {
    for idx, cidr in data.cloudflare_ip_ranges.cloudflare.ipv4_cidrs :
    "allow_cf_ipv4_${idx + 1}" => {
      action     = "Allow"
      ip_address = cidr
      priority   = 200 + idx
      name       = "AllowCloudflareIPv4_${idx + 1}"
    }
  }

  # Dynamic Cloudflare IPv6 rules from data source
  cloudflare_ipv6_restrictions = {
    for idx, cidr in data.cloudflare_ip_ranges.cloudflare.ipv6_cidrs :
    "allow_cf_ipv6_${idx + 1}" => {
      action     = "Allow"
      ip_address = cidr
      priority   = 1000 + idx  # IPv6 rules start at higher priority number
      name       = "AllowCloudflareIPv6_${idx + 1}"
    }
  }

  # Merge all IP restrictions
  all_ip_restrictions = merge(
    local.static_ip_restrictions,
    local.cloudflare_ipv4_restrictions,
    local.cloudflare_ipv6_restrictions
  )
}