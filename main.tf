resource "azurerm_cdn_frontdoor_profile" "front_door_profile" {
  name                     = var.front_door_profile_name
  resource_group_name      = var.resource_group_name
  sku_name                 = "Standard_AzureFrontDoor"
  response_timeout_seconds = var.response_timeout_seconds
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  for_each                 = { for k in var.front_door_endpoints : k.name => k if k != null }
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
  enabled                  = each.value.enabled
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  for_each                 = { for k in var.front_door_custom_domains : k.name => k if k != null }
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
  dns_zone_id              = each.value["dns_zone_id"]
  host_name                = each.value["host_name"]

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  for_each                                                  = { for k in var.front_door_origin_groups : k.name => k if k != null }
  name                                                      = each.key
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.front_door_profile.id
  session_affinity_enabled                                  = each.value["session_affinity_enabled"]
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = each.value["restore_traffic_time_to_healed_or_new_endpoint_in_minutes"]

  dynamic "health_probe" {
    for_each = each.value.health_probes

    content {
      interval_in_seconds = health_probe.value["interval_in_seconds"]
      path                = health_probe.value["path"]
      protocol            = health_probe.value["protocol"]
      request_type        = health_probe.value["request_type"]
    }
  }

  load_balancing {
    additional_latency_in_milliseconds = each.value["additional_latency_in_milliseconds"]
    sample_size                        = each.value["sample_size"]
    successful_samples_required        = each.value["successful_samples_required"]
  }
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  for_each                      = { for k in var.front_door_origins : k.name => k if k != null }
  name                          = each.key
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group[(each.value["origin_group_reference"])].id
  enabled                       = each.value["enabled"]

  certificate_name_check_enabled = each.value["certificate_name_check_enabled"]
  host_name                      = each.value["host_name"]
  origin_host_header             = each.value["origin_host_header"]
  priority                       = each.value["priority"]
  weight                         = each.value["weight"]
  http_port                      = each.value["http_port"]
  https_port                     = each.value["https_port"]

  dynamic "private_link" {
    for_each = each.value["private_link"]

    content {
      request_message        = private_link.value["request_message"]
      target_type            = private_link.value["target_type"]
      location               = private_link.value["location"]
      private_link_target_id = private_link.value["private_link_target_id"]
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "rule_set" {
  for_each                 = { for k in var.front_door_rule_sets : k => k if k != null }
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id
}

resource "azurerm_cdn_frontdoor_rule" "rule" {
  for_each                  = { for k in var.front_door_rules : k.name => k if k != null }
  name                      = each.key
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.rule_set[(each.value["rule_set_reference"])].id
  order                     = each.value["order"]
  behavior_on_match         = each.value["behavior_on_match"]

  actions {

    dynamic "url_rewrite_action" {
      for_each = { for k in each.value["url_rewrite_actions"] : k.name => k if k != null }

      content {
        source_pattern          = url_rewrite_action.value["source_pattern"]
        destination             = url_rewrite_action.value["destination"]
        preserve_unmatched_path = url_rewrite_action.value["preserve_unmatched_path"]
      }
    }

    dynamic "url_redirect_action" {
      for_each = { for k in each.value["url_redirect_actions"] : k.name => k if k != null }

      content {
        redirect_type        = url_redirect_action.value["redirect_type"]
        destination_hostname = url_redirect_action.value["destination_hostname"]
        redirect_protocol    = url_redirect_action.value["redirect_protocol"]
        destination_path     = url_redirect_action.value["destination_path"]
        query_string         = url_redirect_action.value["query_string"]
        destination_fragment = url_redirect_action.value["destination_fragment"]
      }
    }

    dynamic "route_configuration_override_action" {
      for_each = { for k in each.value["route_configuration_override_actions"] : k.name => k if k != null }

      content {
        cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group[(each.value["origin_group_reference"])].id
        forwarding_protocol           = route_configuration_override_action.value["forwarding_protocol"]
        query_string_caching_behavior = route_configuration_override_action.value["query_string_caching_behavior"]
        query_string_parameters       = route_configuration_override_action.value["query_string_parameters"]
        compression_enabled           = route_configuration_override_action.value["compression_enabled"]
        cache_behavior                = route_configuration_override_action.value["cache_behavior"]
        cache_duration                = route_configuration_override_action.value["cache_duration"]
      }
    }

    dynamic "request_header_action" {
      for_each = { for k in each.value["request_header_actions"] : k.name => k if k != null }

      content {
        header_action = request_header_action.value["header_action"]
        header_name   = request_header_action.value["header_name"]
        value         = request_header_action.value["value"]
      }
    }

    dynamic "response_header_action" {
      for_each = { for k in each.value["response_header_actions"] : k.name => k if k != null }

      content {
        header_action = response_header_action.value["header_action"]
        header_name   = response_header_action.value["header_name"]
        value         = response_header_action.value["value"]
      }
    }
  }

  conditions {

    dynamic "remote_address_condition" {
      for_each = { for k in each.value["remote_address_conditions"] : k.name => k if k != null }

      content {
        operator         = remote_address_conditions.value["operator"]
        negate_condition = remote_address_conditions.value["negate_condition"]
        match_values     = remote_address_conditions.value["match_values"]
      }
    }

    dynamic "request_method_condition" {
      for_each = { for k in each.value["request_method_conditions"] : k.name => k if k != null }

      content {
        operator         = request_method_condition.value["operator"]
        negate_condition = request_method_condition.value["negate_condition"]
        match_values     = request_method_condition.value["match_values"]
      }
    }

    dynamic "query_string_condition" {
      for_each = { for k in each.value["query_string_conditions"] : k.name => k if k != null }

      content {
        operator         = query_string_condition.value["operator"]
        negate_condition = query_string_condition.value["negate_condition"]
        match_values     = query_string_condition.value["match_values"]
        transforms       = query_string_condition.value["transforms"]
      }
    }

    dynamic "post_args_condition" {
      for_each = { for k in each.value["post_args_conditions"] : k.name => k if k != null }

      content {
        post_args_name   = post_args_condition.value["post_args_name"]
        operator         = post_args_condition.value["operator"]
        negate_condition = post_args_condition.value["negate_condition"]
        match_values     = post_args_condition.value["match_values"]
        transforms       = post_args_condition.value["transforms"]
      }
    }

    dynamic "request_uri_condition" {
      for_each = { for k in each.value["request_uri_conditions"] : k.name => k if k != null }

      content {
        operator         = request_uri_condition.value["operator"]
        negate_condition = request_uri_condition.value["negate_condition"]
        match_values     = request_uri_condition.value["match_values"]
        transforms       = request_uri_condition.value["transforms"]
      }
    }

    dynamic "request_header_condition" {
      for_each = { for k in each.value["request_header_conditions"] : k.name => k if k != null }

      content {
        header_name      = request_header_condition.value["header_name"]
        operator         = request_header_condition.value["operator"]
        negate_condition = request_header_condition.value["negate_condition"]
        match_values     = request_header_condition.value["match_values"]
        transforms       = request_header_condition.value["transforms"]
      }
    }

    dynamic "request_body_condition" {
      for_each = { for k in each.value["request_body_conditions"] : k.name => k if k != null }

      content {
        operator         = request_body_condition.value["operator"]
        negate_condition = request_body_condition.value["negate_condition"]
        match_values     = request_body_condition.value["match_values"]
        transforms       = request_body_condition.value["transforms"]
      }
    }

    dynamic "request_scheme_condition" {
      for_each = { for k in each.value["request_scheme_conditions"] : k.name => k if k != null }

      content {
        operator         = request_scheme_condition.value["operator"]
        negate_condition = request_scheme_condition.value["negate_condition"]
        match_values     = request_scheme_condition.value["match_values"]
      }
    }

    dynamic "url_path_condition" {
      for_each = { for k in each.value["url_path_conditions"] : k.name => k if k != null }

      content {
        operator         = url_path_condition.value["operator"]
        negate_condition = url_path_condition.value["negate_condition"]
        match_values     = url_path_condition.value["match_values"]
        transforms       = url_path_condition.value["transforms"]
      }
    }

    dynamic "url_file_extension_condition" {
      for_each = { for k in each.value["url_file_extension_conditions"] : k.name => k if k != null }

      content {
        operator         = url_file_extension_condition.value["operator"]
        negate_condition = url_file_extension_condition.value["negate_condition"]
        match_values     = url_file_extension_condition.value["match_values"]
        transforms       = url_file_extension_condition.value["transforms"]
      }
    }

    dynamic "url_filename_condition" {
      for_each = { for k in each.value["url_filename_conditions"] : k.name => k if k != null }

      content {
        operator         = url_filename_condition.value["operator"]
        negate_condition = url_filename_condition.value["negate_condition"]
        match_values     = url_filename_condition.value["match_values"]
        transforms       = url_filename_condition.value["transforms"]
      }
    }

    dynamic "http_version_condition" {
      for_each = { for k in each.value["http_version_conditions"] : k.name => k if k != null }

      content {
        operator         = http_version_condition.value["operator"]
        negate_condition = http_version_condition.value["negate_condition"]
        match_values     = http_version_condition.value["match_values"]
      }
    }

    dynamic "cookies_condition" {
      for_each = { for k in each.value["cookies_conditions"] : k.name => k if k != null }

      content {
        cookie_name      = cookies_condition.value["cookie_name"]
        operator         = cookies_condition.value["operator"]
        negate_condition = cookies_condition.value["negate_condition"]
        match_values     = cookies_condition.value["match_values"]
      }
    }

    dynamic "is_device_condition" {
      for_each = { for k in each.value["is_device_conditions"] : k.name => k if k != null }

      content {
        operator         = is_device_condition.value["operator"]
        negate_condition = is_device_condition.value["negate_condition"]
        match_values     = is_device_condition.value["match_values"]
      }
    }

    dynamic "socket_address_condition" {
      for_each = { for k in each.value["socket_address_conditions"] : k.name => k if k != null }

      content {
        operator         = socket_address_condition.value["operator"]
        negate_condition = socket_address_condition.value["negate_condition"]
        match_values     = socket_address_condition.value["match_values"]
      }
    }

    dynamic "client_port_condition" {
      for_each = { for k in each.value["client_port_conditions"] : k.name => k if k != null }

      content {
        operator         = client_port_condition.value["operator"]
        negate_condition = client_port_condition.value["negate_condition"]
        match_values     = client_port_condition.value["match_values"]
      }
    }

    dynamic "server_port_condition" {
      for_each = { for k in each.value["server_port_conditions"] : k.name => k if k != null }

      content {
        operator         = server_port_condition.value["operator"]
        negate_condition = server_port_condition.value["negate_condition"]
        match_values     = server_port_condition.value["match_values"]
      }
    }

    dynamic "host_name_condition" {
      for_each = { for k in each.value["host_name_conditions"] : k.name => k if k != null }

      content {
        operator         = host_name_condition.value["operator"]
        negate_condition = host_name_condition.value["negate_condition"]
        match_values     = host_name_condition.value["match_values"]
        transforms       = host_name_condition.value["transforms"]
      }
    }

    dynamic "ssl_protocol_condition" {
      for_each = { for k in each.value["ssl_protocol_conditions"] : k.name => k if k != null }

      content {
        operator         = is_device_condition.value["operator"]
        negate_condition = is_device_condition.value["negate_condition"]
        match_values     = is_device_condition.value["match_values"]
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "route" {
  for_each                        = { for k in var.front_door_routes : k.name => k if k != null }
  name                            = each.key
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.endpoint[(each.value["endpoint_reference"])].id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_endpoint.endpoint[(each.value["origin_group_reference"])].id
  cdn_frontdoor_origin_ids        = [for k in setintersection(local.deployed_origin_names, each.value["origin_references"]) : azurerm_cdn_frontdoor_origin.origin[(k)].id]
  cdn_frontdoor_rule_set_ids      = [for k in setintersection(local.deployed_rule_set_names, each.value["rule_set_references"]) : azurerm_cdn_frontdoor_rule_set.rule_set[(k)].id]
  enabled                         = each.value["enabled"]
  forwarding_protocol             = each.value["forwarding_protocol"]
  https_redirect_enabled          = each.value["https_redirect_enabled"]
  patterns_to_match               = each.value["patterns_to_match"]
  supported_protocols             = each.value["supported_protocols"]
  cdn_frontdoor_custom_domain_ids = [for k in setintersection(local.deployed_custom_domain_names, each.value["custom_domain_references"]) : azurerm_cdn_frontdoor_custom_domain.custom_domain[(k)].id]
  link_to_default_domain          = each.value["link_to_default_domain"]

  cache {
    query_string_caching_behavior = each.value["query_string_caching_behavior"]
    query_strings                 = each.value["query_strings"]
    compression_enabled           = each.value["compression_enabled"]
    content_types_to_compress     = each.value["content_types_to_compress"]
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  name                     = var.front_door_security_policy["name"]
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.front_door_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = data.azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        patterns_to_match = var.front_door_security_policy["patterns_to_match"]
        dynamic "domain" {
          for_each = { for k in var.front_door_security_policy["custom_domain_references"] : k => k }

          content {
            cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.custom_domain[(domain.key)].id
          }
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "front_door_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_cdn_frontdoor_profile.front_door_profile.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "FrontDoorAccessLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "FrontDoorHealthProbeLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "FrontDoorWebApplicationFirewallLog"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
