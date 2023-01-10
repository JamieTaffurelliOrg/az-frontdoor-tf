locals {
  deployed_origin_names        = [for k in azurerm_cdn_frontdoor_origin.origin : k.name]
  deployed_rule_set_names      = [for k in azurerm_cdn_frontdoor_rule_set.rule_set : k.name]
  deployed_custom_domain_names = [for k in azurerm_cdn_frontdoor_custom_domain.custom_domain : k.name]
}
