
module "managed_identities" {
  source   = "./modules/security/managed_identity"
  for_each = var.managed_identities

  client_config       = local.client_config
  global_settings     = local.global_settings
  name                = each.value.name
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.resource_groups
  resource_group_name = local.resource_groups
  base_tags           = try(local.global_settings.inherit_tags, false) ? try(local.resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags, {}) : {}
}

output "managed_identities" {
  value = module.managed_identities

}