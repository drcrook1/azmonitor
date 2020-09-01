#!/bin/bash

az login
cd ./terraform
bash ./terraform_deploy.sh
##Add the deployment of the fun tion code##
bash ./deploy_func.sh