data "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                = var.waf_policy_name
  resource_group_name = var.waf_policy_resource_group_name
}

data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
