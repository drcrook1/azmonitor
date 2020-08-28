#!/bin/bash

red=$'\e[1;31m'
green=$'\e[1;32m'
blue=$'\e[1;34m'
magenta=$'\e[1;35m'
cyan=$'\e[1;36m'
white=$'\e[0m'

cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{

  message=${1}   # Defaults to default message.
  color=${2}           # Defaults to black, if not specified.

  echo $color "$message" $white

  return
}

export TF_VAR_location="$TARGET_LOCATION"
export TF_VAR_environment="$TARGET_ENV"
export TF_VAR_sqluser="$SQL_USERNAME"
export TF_VAR_sqlpassword="$SQL_PASSWORD"

#
# Sample for how to set up a service principal, we aren't doing this, we are using interactive login instead.
# This is how you would really do this in a proper dev ops pipeline.
#
# export ARM_CLIENT_ID="$SP_APP_ID"
# export ARM_CLIENT_SECRET="$SP_APP_PW"
# export ARM_SUBSCRIPTION_ID="$AZ_SUB_ID"
# export ARM_TENANT_ID="$SP_APP_TENANT_ID"
# export ARM_ACCESS_KEY="$TARGET_RS_STORAGE_ACCESS_KEY"
# export TF_VAR_sp_deploy_app_id="$SP_APP_ID"
# export TF_VAR_sp_deploy_app_pw="$SP_APP_PW"

#
# This is how you would properly set up remote state management, we aren't doing this either.
#
# cecho "Starting Terraform Init..." $magenta
# terraform init -backend-config=storage_account_name="$TARGET_RS_STORAGE_ACCOUNT" -backend-config=container_name="$TARGET_RS_CONTAINER_NAME" -backend-config=key="$TARGET_RS_KEY" -backend-config=resource_group_name="$TARGET_RS_RG"
# terraform import azurerm_resource_group.rg /subscriptions/"$AZ_SUB_ID"/resourceGroups/esi-"$TARGET_ENV" 2>/dev/null
# cecho "Completed Terraform Init..." $green


#
# This is the simplest way to set it up, not secure or whatever, but works for an open sourced example.
#
terraform init

cecho "Starting Terraform Plan..." $magenta
terraform plan -out=tfplan.out
cecho "Completed Terraform Plan..." $green

cecho "Starting Terraform Apply..." $magenta
terraform apply -auto-approve "tfplan.out"
cecho "Completed Terraform Apply..." $green


cecho "Writing Key Outputs to Files for next stages" $green
# mkdir -p ~/.kube
# terraform output kube_config >> ~/.kube/config

# public_ip=$(terraform output ingress_public_ip)
# cecho "PUBLIC IP IS: $public_ip" $red