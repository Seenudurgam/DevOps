#! /bin/bash

# ---- validate variables ----

if [[ -z "${APP_STAGE}" ]]
then
  echo "ERROR APP_STAGE variable not defined."
  exit 1
fi

if [[ -z "${APP_SAY_MY_NAME}" ]]
then
  echo "ERROR APP_SAY_MY_NAME variable not defined."
  exit 1
fi

# --- go to stage ----

cd ./stages/${APP_STAGE}
if [[ $? -ne 0 ]]
then
  echo "ERROR Failed to navigate to folder ./stages/${APP_STAGE}."
  exit 1
fi

# ---- terraform variables ----

export TF_VAR_app_say_my_name=${APP_SAY_MY_NAME}
# TODO: add more

# -- disable resources --

export TF_VAR_app_enable_key_vault="false"

# ---- init terraform ----

./terraform --version
./terraform init -no-color

if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform init failed."
  exit 4
fi

# ---- plan terraform ----

./terraform plan -no-color
if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform paln failed."
  exit 5
fi

# ---- apply terraform ----

./terraform apply -auto-approve -no-color
if [[ $? -ne 0 ]]
then
  echo "ERROR Terraform apply failed."
  exit 6
fi
