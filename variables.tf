variable "resource_group_name" {
  type        = string
  description = "Resource Group name to deploy to"
}

variable "front_door_profile_name" {
  type        = string
  description = "Name of the Front Door"
}

variable "response_timeout_seconds" {
  type        = number
  default     = 120
  description = "Maximum response timeout in seconds"
}

variable "waf_policy_name" {
  type        = string
  description = "Name of WAF policy to attach to Front Door"
}

variable "waf_policy_resource_group_name" {
  type        = string
  description = "Resource group of WAF policy to attach to Front Door"
}

variable "front_door_endpoints" {
  type = list(object(
    {
      name    = string
      enabled = optional(bool, true)
    }
  ))
  default     = []
  description = "Front door endpoints"
}

variable "front_door_custom_domains" {
  type = list(object(
    {
      name        = string
      dns_zone_id = optional(string)
      host_name   = string
    }
  ))
  default     = []
  description = "Front door custom domains"
}

variable "front_door_origin_groups" {
  type = list(object(
    {
      name                                                      = string
      session_affinity_enabled                                  = optional(bool, true)
      restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)
      health_probes = map(object({
        interval_in_seconds = optional(number, 5)
        path                = optional(string, "/")
        protocol            = string
        request_type        = optional(string, "HEAD")
      }))
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }
  ))
  default     = []
  description = "Front door origin groups"
}

variable "front_door_origins" {
  type = list(object(
    {
      name                           = string
      origin_group_reference         = string
      enabled                        = optional(bool, true)
      certificate_name_check_enabled = optional(bool, true)
      host_name                      = string
      origin_host_header             = optional(string)
      priority                       = optional(number, 1)
      weight                         = optional(number, 500)
      http_port                      = optional(number, 80)
      https_port                     = optional(number, 443)
      private_link = optional(map(object({
        request_message        = optional(string, "Access request for CDN FrontDoor Private Link Origin")
        target_type            = string
        location               = string
        private_link_target_id = string
      })), {})
    }
  ))
  default     = []
  description = "Front door origins"
}

variable "front_door_rule_sets" {
  type        = list(string)
  default     = []
  description = "Front door rule sets"
}

variable "front_door_rules" {
  type = list(object(
    {
      name               = string
      rule_set_reference = string
      order              = number
      behavior_on_match  = string
      url_rewrite_actions = optional(list(object({
        name                    = string
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, false)
      })), [])
      url_redirect_actions = optional(list(object({
        name                 = string
        redirect_type        = string
        destination_hostname = string
        redirect_protocol    = optional(string, "MatchRequest")
        destination_path     = optional(string, "")
        query_string         = optional(string, "")
        destination_fragment = optional(string, "")
      })), [])
      route_configuration_override_actions = optional(list(object({
        name                          = string
        origin_group_reference        = optional(string)
        forwarding_protocol           = optional(string)
        query_string_caching_behavior = optional(string)
        query_string_parameters       = optional(string)
        compression_enabled           = optional(string, true)
        cache_behavior                = optional(string)
        cache_duration                = optional(string)
      })), [])
      request_header_actions = optional(list(object({
        name          = string
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
      response_header_action = optional(list(object({
        name          = string
        header_action = string
        header_name   = string
        value         = optional(string)
      })), [])
      remote_address_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = optional(list(string))
      })), [])
      request_method_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = list(string)
      })), [])
      query_string_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      post_args_conditions = optional(list(object({
        name             = string
        post_args_name   = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      request_uri_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      request_header_conditions = optional(list(object({
        name             = string
        header_name      = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      request_body_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = list(string)
        transforms       = optional(string)
      })), [])
      request_scheme_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = optional(list(string))
      })), [])
      url_path_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      url_file_extension_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = list(string)
        transforms       = optional(string)
      })), [])
      url_filename_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = list(string)
        transforms       = optional(string)
      })), [])
      http_version_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = list(string)
      })), [])
      cookies_conditions = optional(list(object({
        name             = string
        cookie_name      = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      is_device_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = optional(list(string))
      })), [])
      socket_address_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = optional(list(string))
      })), [])
      client_port_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
      })), [])
      server_port_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = list(string)
      })), [])
      host_name_conditions = optional(list(object({
        name             = string
        operator         = string
        negate_condition = optional(bool)
        match_values     = optional(list(string))
        transforms       = optional(string)
      })), [])
      ssl_protocol_conditions = optional(list(object({
        name             = string
        operator         = optional(string)
        negate_condition = optional(bool)
        match_values     = list(string)
      })), [])
    }
  ))
  default     = []
  description = "Front door rules"
}

variable "front_door_routes" {
  type = list(object(
    {
      name                          = string
      endpoint_reference            = string
      origin_group_reference        = string
      origin_references             = optional(list(string))
      rule_set_references           = optional(list(string), [])
      enabled                       = optional(bool, true)
      forwarding_protocol           = optional(string)
      https_redirect_enabled        = optional(bool, true)
      patterns_to_match             = list(string)
      supported_protocols           = optional(list(string), ["Http", "Https"])
      custom_domain_references      = optional(list(string))
      link_to_default_domain        = bool
      query_string_caching_behavior = optional(string)
      query_strings                 = optional(list(string))
      compression_enabled           = optional(bool)
      content_types_to_compress     = optional(list(string))
    }
  ))
  default     = []
  description = "Front door routes"
}

variable "front_door_security_policy" {
  type = object({
    name                     = string
    patterns_to_match        = optional(list(string), ["/*"])
    custom_domain_references = list(string)
  })
  description = "Front door security policy"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
