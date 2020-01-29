#!/bin/bash

if [[ "${TERRAFORM_SKIP}" == "true" ]]
then
  echo "SKIPPING Terraform provisioning skipped due to TERRAFORM_SKIP was to ${TERRAFORM_SKIP}."
  exit 0
fi

# APP Variables

if [[ -z "${APP_CLIENT_ID}" ]]
then
  echo "ERROR APP_CLIENT_ID variable not defined."
  exit 1
fi

if [[ -z "${APP_CLIENT_SECRET}" ]]
then
  echo "ERROR APP_CLIENT_SECRET variable not defined."
  exit 1
fi

if [[ -z "${APP_SUBSCRIPTION_ID}" ]]
then
  echo "ERROR APP_SUBSCRIPTION_ID variable not defined."
  exit 1
fi

if [[ -z "${APP_TENANT_ID}" ]]
then
  echo "ERROR APP_TENANT_ID variable not defined."
  exit 1
fi

if [[ -z "${APP_STAGE}" ]]
then
  echo "ERROR APP_STAGE variable not defined."
  exit 1
fi

if [[ -z "${APP_LOCATION}" ]]
then
  echo "ERROR APP_LOCATION variable not defined."
  exit 1
fi

if [[ -z "${APP_NAME}" ]]
then
  echo "ERROR APP_NAME variable not defined."
  exit 1
fi

cd ${SYSTEM_DEFAULTWORKINGDIRECTORY}/Source/terraform/stages/${RELEASE_ENVIRONMENTNAME}
if [[ $? -ne 0 ]]
then
  echo "ERROR Failed to navigate to folder ${SYSTEM_DEFAULTWORKINGDIRECTORY}/Source/terraform/stages/${RELEASE_ENVIRONMENTNAME}."
  exit 1
fi

# AZ select APP CLOUD

if [[ "${APP_CLOUD}" == "china" ]]
then
  echo "Setting APP cloud to AzureChinaCloud."
  az cloud set --name AzureChinaCloud
else
  echo "Setting APP cloud to AzureCloud."
  az cloud set --name AzureCloud
fi

# AZ login

az login \
--service-principal \
--tenant ${APP_TENANT_ID} -u ${APP_CLIENT_ID} -p ${APP_CLIENT_SECRET} \
--output table
if [[ $? -ne 0 ]]
then
  echo "ERROR Azure login failed."
  exit 2
fi

# Create storage account for terraform state if not exists
az group create \
--subscription ${APP_SUBSCRIPTION_ID} \
--location ${APP_LOCATION} \
--name ${APP_STORAGE_RESOURCE_GROUP}

az storage account create \
--subscription ${APP_SUBSCRIPTION_ID} \
--name ${APP_STORAGE_NAME} \
--resource-group ${APP_STORAGE_RESOURCE_GROUP} \
--location ${APP_LOCATION} \
--kind BlobStorage \
--access-tier Hot \
--sku Standard_GRS

APP_STORAGE_KEY=$(az storage account keys list \
--subscription ${APP_SUBSCRIPTION_ID} \
--resource-group ${APP_STORAGE_RESOURCE_GROUP} \
--account-name ${APP_STORAGE_NAME} \
--query [0].value -o tsv)
if [[ $? -ne 0 ]]
then
  echo "ERROR Failed to read Azure storage access key."
  echo "Create a storage account in your subscription in:"
  echo "resource-group: ${APP_STORAGE_RESOURCE_GROUP}"
  echo "name: ${APP_STORAGE_NAME}"
  exit 3
fi

az storage container create \
--subscription ${APP_SUBSCRIPTION_ID} \
--account-name ${APP_STORAGE_NAME} \
--account-key ${APP_STORAGE_KEY} \
--name app

az logout
az account list --output table

# Terraform

export ARM_ENVIRONMENT=public
if [[ "${APP_CLOUD}" == "china" ]]
then
  ARM_ENVIRONMENT=china
fi
export ARM_SUBSCRIPTION_ID=${APP_SUBSCRIPTION_ID}
export ARM_CLIENT_ID=${APP_CLIENT_ID}
export ARM_CLIENT_SECRET=${APP_CLIENT_SECRET}
export ARM_TENANT_ID=${APP_TENANT_ID}
export ARM_ACCESS_KEY=${APP_STORAGE_KEY}

export TF_VAR_app_subscription_id=${APP_SUBSCRIPTION_ID}
export TF_VAR_app_client_id=${APP_CLIENT_ID}
export TF_VAR_app_client_secret=${APP_CLIENT_SECRET}
export TF_VAR_app_tenant_id=${APP_TENANT_ID}
export TF_VAR_app_stage=${APP_STAGE}
export TF_VAR_app_location=${APP_LOCATION}
export TF_VAR_app_name=${APP_NAME}

export TF_VERSION=0.12.8
curl -LO https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
unzip terraform_${TF_VERSION}_linux_amd64.zip -d .
rm -f terraform_${TF_VERSION}_linux_amd64.zip
chmod +x terraform

./terraform --version
./terraform init -no-color \
-backend-config="environment=${APP_STORAGE_ENVIRONMENT}" \
-backend-config="storage_account_name=${APP_STORAGE_NAME}" \
-backend-config="container_name=app" \
-backend-config="key=${APP_NAME}.tfstate"
if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform init failed."
  exit 4
fi
./terraform plan -no-color
if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform paln failed."
  exit 5
fi
./terraform apply -auto-approve -no-color
if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform apply failed."
  exit 6
fi
