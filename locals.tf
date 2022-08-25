resource "random_string" "prefix" {
  count   = try(var.global_settings.prefix, null) == null ? 1 : 0
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  azuread = {
    azuread_api_permissions             = try(var.azuread.azuread_api_permissions, {})
    azuread_applications                = try(var.azuread.azuread_applications, {})
    azuread_apps                        = try(var.azuread.azuread_apps, {})
    azuread_credential_policies         = try(var.azuread.azuread_credential_policies, {})
    azuread_credentials                 = try(var.azuread.azuread_credentials, {})
    azuread_groups                      = try(var.azuread.azuread_groups, {})
    azuread_groups_membership           = try(var.azuread.azuread_groups_membership, {})
    azuread_roles                       = try(var.azuread.azuread_roles, {})
    azuread_service_principal_passwords = try(var.azuread.azuread_service_principal_passwords, {})
    azuread_service_principals          = try(var.azuread.azuread_service_principals, {})
    azuread_users                       = try(var.azuread.azuread_users, {})
  }
}