output "front_door_profile_id" {
  value       = azurerm_cdn_frontdoor_profile.front_door_profile.id
  description = "The resource ID of the front door profile"
}

output "front_door_profile_guid" {
  value       = azurerm_cdn_frontdoor_profile.front_door_profile.resource_guid
  sensitive   = true
  description = "UUID of this Front Door Profile which will be sent in the HTTP Header as the X-Azure-FDID attribute"
}
