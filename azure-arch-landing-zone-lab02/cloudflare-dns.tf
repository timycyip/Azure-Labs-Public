
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "hello_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "hello"
  content = module.azurerm_cdn_frontdoor_profile.frontdoor_endpoints["ep1_key"].host_name
  type    = "CNAME"
  ttl     = 60
  proxied = false
}
