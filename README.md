# az-frontdoor-tf

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.20 |
| <a name="provider_azurerm.logs"></a> [azurerm.logs](#provider\_azurerm.logs) | ~> 3.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_custom_domain.custom_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.origin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.front_door_profile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.rule_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_security_policy.security_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) | resource |
| [azurerm_monitor_diagnostic_setting.front_door_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_cdn_frontdoor_firewall_policy.waf_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/cdn_frontdoor_firewall_policy) | data source |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_front_door_custom_domains"></a> [front\_door\_custom\_domains](#input\_front\_door\_custom\_domains) | Front door custom domains | <pre>list(object(<br>    {<br>      name        = string<br>      dns_zone_id = optional(list(string))<br>      host_name   = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_endpoints"></a> [front\_door\_endpoints](#input\_front\_door\_endpoints) | Front door endpoints | <pre>list(object(<br>    {<br>      name    = string<br>      enabled = optional(bool, true)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_origin_groups"></a> [front\_door\_origin\_groups](#input\_front\_door\_origin\_groups) | Front door origin groups | <pre>list(object(<br>    {<br>      name                                                      = string<br>      session_affinity_enabled                                  = optional(bool, true)<br>      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)<br>      health_probes = map(object({<br>        interval_in_seconds = optional(number, 5)<br>        path                = optional(string, "/")<br>        protocol            = string<br>        request_type        = optional(string, "HEAD")<br>      }))<br>      additional_latency_in_milliseconds = optional(number, 50)<br>      sample_size                        = optional(number, 4)<br>      successful_samples_required        = optional(number, 3)<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_origins"></a> [front\_door\_origins](#input\_front\_door\_origins) | Front door origins | <pre>list(object(<br>    {<br>      name                           = string<br>      origin_group_reference         = string<br>      enabled                        = optional(bool, true)<br>      certificate_name_check_enabled = optional(bool, true)<br>      host_name                      = string<br>      origin_host_header             = optional(string)<br>      priority                       = optional(number, 1)<br>      weight                         = optional(number, 500)<br>      http_port                      = optional(number, 80)<br>      https_port                     = optional(number, 443)<br>      private_link = optional(map(object({<br>        request_message        = optional(string, "Access request for CDN FrontDoor Private Link Origin")<br>        target_type            = string<br>        location               = string<br>        private_link_target_id = string<br>      })), {})<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_profile_name"></a> [front\_door\_profile\_name](#input\_front\_door\_profile\_name) | Name of the Front Door | `string` | n/a | yes |
| <a name="input_front_door_routes"></a> [front\_door\_routes](#input\_front\_door\_routes) | Front door routes | <pre>list(object(<br>    {<br>      name                          = string<br>      endpoint_reference            = string<br>      origin_group_reference        = string<br>      origin_references             = optional(list(string))<br>      rule_set_references           = optional(list(string))<br>      enabled                       = optional(bool, true)<br>      forwarding_protocol           = optional(string)<br>      https_redirect_enabled        = optional(bool, true)<br>      patterns_to_match             = list(string)<br>      supported_protocols           = string<br>      custom_domain_references      = optional(list(string))<br>      link_to_default_domain        = bool<br>      query_string_caching_behavior = optional(string)<br>      query_strings                 = optional(list(string))<br>      compression_enabled           = optional(bool)<br>      content_types_to_compress     = optional(list(string))<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_rule_sets"></a> [front\_door\_rule\_sets](#input\_front\_door\_rule\_sets) | Front door rule sets | `list(string)` | `[]` | no |
| <a name="input_front_door_rules"></a> [front\_door\_rules](#input\_front\_door\_rules) | Front door rules | <pre>list(object(<br>    {<br>      name               = string<br>      rule_set_reference = string<br>      order              = number<br>      behavior_on_match  = string<br>      url_rewrite_actions = optional(list(object({<br>        name                    = string<br>        source_pattern          = string<br>        destination             = string<br>        preserve_unmatched_path = optional(bool, false)<br>      })), [])<br>      url_redirect_actions = optional(list(object({<br>        name                 = string<br>        redirect_type        = string<br>        destination_hostname = string<br>        redirect_protocol    = optional(string, "MatchRequest")<br>        destination_path     = optional(string, "")<br>        query_string         = optional(string, "")<br>        destination_fragment = optional(string, "")<br>      })), [])<br>      route_configuration_override_actions = optional(list(object({<br>        name                          = string<br>        origin_group_reference        = optional(string)<br>        forwarding_protocol           = optional(string)<br>        query_string_caching_behavior = optional(string)<br>        query_string_parameters       = optional(string)<br>        compression_enabled           = optional(string, true)<br>        cache_behavior                = optional(string)<br>        cache_duration                = optional(string)<br>      })), [])<br>      request_header_actions = optional(list(object({<br>        name          = string<br>        header_action = string<br>        header_name   = string<br>        value         = optional(string)<br>      })), [])<br>      response_header_action = optional(list(object({<br>        name          = string<br>        header_action = string<br>        header_name   = string<br>        value         = optional(string)<br>      })), [])<br>      remote_address_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>      })), [])<br>      request_method_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>      })), [])<br>      query_string_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      post_args_conditions = optional(list(object({<br>        name             = string<br>        post_args_name   = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      request_uri_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      request_header_conditions = optional(list(object({<br>        name             = string<br>        header_name      = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      request_body_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>        transforms       = optional(string)<br>      })), [])<br>      request_scheme_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>      })), [])<br>      url_path_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      url_file_extension_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>        transforms       = optional(string)<br>      })), [])<br>      url_filename_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>        transforms       = optional(string)<br>      })), [])<br>      http_version_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>      })), [])<br>      cookies_conditions = optional(list(object({<br>        name             = string<br>        cookie_name      = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      is_device_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>      })), [])<br>      socket_address_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>      })), [])<br>      client_port_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>      })), [])<br>      server_port_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>      })), [])<br>      host_name_conditions = optional(list(object({<br>        name             = string<br>        operator         = string<br>        negate_condition = optional(bool)<br>        match_values     = optional(list(string))<br>        transforms       = optional(string)<br>      })), [])<br>      ssl_protocol_conditions = optional(list(object({<br>        name             = string<br>        operator         = optional(string)<br>        negate_condition = optional(bool)<br>        match_values     = list(string)<br>      })), [])<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_front_door_security_policy"></a> [front\_door\_security\_policy](#input\_front\_door\_security\_policy) | Front door security policy | <pre>object({<br>    name                     = string<br>    patterns_to_match        = optional(list(string), ["/*"])<br>    custom_domain_references = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | Resource Group of Log Analytics Workspace to send diagnostics | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name to deploy to | `string` | n/a | yes |
| <a name="input_response_timeout_seconds"></a> [response\_timeout\_seconds](#input\_response\_timeout\_seconds) | Maximum response timeout in seconds | `number` | `120` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | n/a | yes |
| <a name="input_waf_policy_name"></a> [waf\_policy\_name](#input\_waf\_policy\_name) | Name of WAF policy to attach to Front Door | `string` | n/a | yes |
| <a name="input_waf_policy_resource_group_name"></a> [waf\_policy\_resource\_group\_name](#input\_waf\_policy\_resource\_group\_name) | Resource group of WAF policy to attach to Front Door | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_front_door_profile_guid"></a> [front\_door\_profile\_guid](#output\_front\_door\_profile\_guid) | UUID of this Front Door Profile which will be sent in the HTTP Header as the X-Azure-FDID attribute |
| <a name="output_front_door_profile_id"></a> [front\_door\_profile\_id](#output\_front\_door\_profile\_id) | The resource ID of the front door profile |
<!-- END_TF_DOCS -->
