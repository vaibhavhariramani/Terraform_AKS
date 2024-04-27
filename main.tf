terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}
# fetching Azure Active Directory(AD) config
data "azuread_client_config" "current" {}
# Fetching  User details from Resource Manage Subscription
data "azurerm_subscription" "current" {}
# Creating Azure AD Application
resource "azuread_application" "main" {
  display_name = var.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
  depends_on = [
    azurerm_resource_group.rg1
  ]
}
# Creating AzureAD Service Principle
resource "azuread_service_principal" "main" {
  client_id                    = azuread_application.main.client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
  depends_on = [
    azurerm_resource_group.rg1
  ]
}
# Creates and holds Service Principle Id created in previous  step to be used by other resources
resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.object_id
  depends_on = [
    azuread_service_principal.main
  ]
}
# Assigning role
resource "azurerm_role_assignment" "rolespn" {

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.main.object_id

  depends_on = [
    azuread_service_principal.main
  ]
}
# Fetching Azure Resource Manager Client Configuration
data "azurerm_client_config" "current" {}
# Creating the Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"


  depends_on = [
    azuread_service_principal.main
  ]

}
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id


  # key_permissions = [
  #   "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
  # ]

  secret_permissions = ["Get", "List", "Set", "Delete","Purge"]

}
# Creating Key Vault Secret
resource "azurerm_key_vault_secret" "example" {
  name         = azuread_service_principal.main.client_id
  value        = azuread_service_principal_password.main.value
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_key_vault_access_policy.example
  ]
  
}

#create Azure Kubernetes Service
module "aks" {
  source                 = "./modules/aks"
  aks_cluster_name       = var.cluster-name
  location               = var.location
  resource_group_name    = var.rgname
  service_principal_name = var.service_principal_name
  client_id              = azuread_application.main.client_id
  client_secret          = azuread_service_principal_password.main.value
  

  depends_on = [
    azuread_service_principal.main,
    azuread_service_principal_password.main
  ]

}

# module "k8s" {
#   source                = "./modules/k8s/"
#   host                  = "${module.aks.host}"
#   client_certificate    = "${base64decode(module.aks.client_certificate)}"
#   client_key            = "${base64decode(module.aks.client_key)}"
#   cluster_ca_certificate= "${base64decode(module.aks.cluster_ca_certificate)}"
# }