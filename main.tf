
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99"
      configuration_aliases = [
        azurerm.vhub
      ]
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 0.2.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      version = "~> 3.3.1"
      source  = "hashicorp/random"
    }
  }
  required_version = ">= 1.1.0"
}


data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}

# The rover handle the identity management transition to cover interactive run and execution on pipelines using azure ad applications or managed identities
# There are different scenrios are considered:
#
# 1 - running launchpad from vscode
#  In this bootstrap scenario the launchpad is executed under a logged in user azure session. The rover sets the logged_user_objectId through environment variable. During that initial run an Azure AD application (refered as launchpad_app_level0) is created to support any execution from a pipeline.
# 2 - deploying a landing zone or a solution from vscode
#  Step 1 has been executed. The rover is still connected to a logged in user azure session. The rover use the user's credentials to connect the default azure subscription to identity the storage account and the keyvault holding the tfstate and the launchpad_app_level0 credentials. The rover set the terraform ARM_* variables to change the terraform provider Azure context (client id, secret, tenant and subscription). The logged_aad_app_objectId is set to the launchpad_app_level0's client_id. Note in that scenario the azure session does not change. Meaning when terraform execute some local execution scripts they are executed in the context of the logged_in_user and not the azure ad application. To simulate from vscode the execution of a local exec with the launchpad_app_level0 credentials, the rover must be executed with the parameter --impersonate (cannot be used during the launchpad initial deployment and destruciton)


data "azuread_service_principal" "logged_in_app" {
  count          = var.logged_aad_app_objectId == null ? 0 : 1
  application_id = data.azurerm_client_config.current.client_id
}



module "keyvault_access_policies" {
  source   = "./modules/keyvault_access_policies"
  for_each = var.keyvault_access_policies

  keyvault_key    = each.key
  keyvaults       = local.combined_objects_keyvaults
  access_policies = each.value
  azuread_groups  = local.combined_objects_azuread_groups
  client_config   = local.client_config
  resources = {
    azuread_service_principals        = local.combined_objects_azuread_service_principals
    diagnostic_storage_accounts       = local.combined_objects_diagnostic_storage_accounts
    managed_identities                = local.combined_objects_managed_identities
    mssql_managed_instances           = local.combined_objects_mssql_managed_instances
    mssql_managed_instances_secondary = local.combined_objects_mssql_managed_instances_secondary
    storage_accounts                  = local.combined_objects_storage_accounts
  }
}

module "caf" {
  source  = "aztfmod/caf/azurerm"
  version = "~>5.5.0"
  # insert the 7 required variables here
}