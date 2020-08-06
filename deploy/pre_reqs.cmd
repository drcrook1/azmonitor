az login
az group create --name <RESOURCE_GROUP> --location eastus
az identity create -g <RESOURCE_GROUP> -n <YOUR_USER_IDENTITY_NAME>