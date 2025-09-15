
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}

# Data source to fetch current Cloudflare IP ranges
data "cloudflare_ip_ranges" "cloudflare" {
  # This data source retrieves all current Cloudflare IPv4 and IPv6 CIDR blocks
  # It automatically stays current with Cloudflare's IP range updates
}

resource "cloudflare_dns_record" "hello_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "hello"
  content = module.azurerm_cdn_frontdoor_profile.frontdoor_endpoints["ep1_key"].host_name
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_dns_record" "hello_custom_domain_verification" {
  zone_id = var.cloudflare_zone_id
  name    = "_dnsauth.hello"
  content = module.azurerm_cdn_frontdoor_profile.frontdoor_custom_domains["hello_domain"].validation_token
  type    = "TXT"
  ttl     = 300
  proxied = false
  
  depends_on = [ module.azurerm_cdn_frontdoor_profile ]
}
