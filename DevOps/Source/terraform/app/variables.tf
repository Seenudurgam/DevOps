variable "app_stage" {
  description = "Which stage? Example: ece-devweub-driauth, ece-devweub-g3lns..."
}

variable "app_location" {
  description = "Which location? Example: northeurope, westeurope, westus..."
}

variable "app_name" {
  description = "Type name of microservice. Example: car-sharing-service"
}

variable "app_environment" {
  description = "Type the azure environment of your app subscription. Example: public, german, china"
  default = "public"
}

variable "app_subscription_id" {
  description = "Type the azure subscription id of your app subscription. Example: 00000000-0000-0000-0000-000000000000"
}

variable "app_client_id" {
  description = "Type the azure client id of your app subscription. Example: 00000000-0000-0000-0000-000000000000"
}

variable "app_client_secret" {
  description = "Type the azure client secret of your app subscription. Example: 00000000-0000-0000-0000-000000000000"
}

variable "app_tenant_id" {
  description = "Type the azure tenant id of your app subscription. Example: 00000000-0000-0000-0000-000000000000"
}

variable "app_enable_key_vault" {
  default = true
}