#!/bin/bash

az login
cd ./terraform
source ./terraform_deploy.sh
##Add the deployment of the function code##
cd ..
source ./deploy_func.sh
##Add the deployment of the webApp code##
cd ..
cd ..
cd ./deploy
source ./deploy_app.sh