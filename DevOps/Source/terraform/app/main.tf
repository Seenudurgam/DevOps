provider "azurerm" {
  alias           = "app"
  environment     = var.app_environment
  subscription_id = var.app_subscription_id
  client_id       = var.app_client_id
  client_secret   = var.app_client_secret
  tenant_id       = var.app_tenant_id
}

locals {
     resource_group_name = "mmech-ugm-${var.app_stage}-rg"
     resource_group_name_common ="mmech-ugm-${var.app_stage}-common-rg"
     keyvault_name = "mmech-ugmkv-${var.app_stage}"
 }

 # Create a resource group
resource "azurerm_resource_group" "demorg" {
   name     = local.resource_group_name
   location = var.app_location
 }
 # Create a resource group for common resources
 resource "azurerm_resource_group" "democommonrg" {
   name     = local.resource_group_name_common
   location = var.app_location
 }

 #Manages a Key Vault.

resource "azurerm_key_vault" "demokv" {

  count = var.app_enable_key_vault ? 1 : 0

  name                        = local.keyvault_name
  location                    = var.app_location
  resource_group_name         = azurerm_resource_group.democommonrg.name
  enabled_for_disk_encryption = true
  tenant_id                   = "ac67e308-1f19-4011-9baa-c4df0351e262"

  sku_name = "standard"

  access_policy { 
    tenant_id = var.app_tenant_id
    object_id = "1c584611-915e-4307-a62a-36f4ff1828fd"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "demo"
  }
}