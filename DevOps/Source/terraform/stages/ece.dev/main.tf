terraform {
}

# --- environment variables ---
variable "app_subscription_id" {}
variable "app_client_id" {}
variable "app_client_secret" {}
variable "app_tenant_id" {}
variable "app_stage" {}
variable "app_location" {}
variable "app_name" {}

variable "app_enable_key_vault" {}

module "app" {
  source = "../../app/"

  # --- general ---
  app_subscription_id = var.app_subscription_id
  app_client_id       = var.app_client_id
  app_client_secret   = var.app_client_secret
  app_tenant_id       = var.app_tenant_id
  app_stage           = var.app_stage
  app_location        = var.app_location
  #app_key             = var.app_key
  app_name            = var.app_name
  
  # ---- key vault ----
  app_enable_key_vault = var.app_enable_key_vault
}