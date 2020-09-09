echo "Deploying Web App code using Az commands"
cd ..
cd ./Src/WebApp

echo "database firewall updating..."
az sql server firewall-rule create -g azmonitor-$TARGET_ENV --server azmonitorsqlserver$TARGET_ENV -n firewallIPRange --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
echo "Attemp to read Terraform output"
MY_SQL_DB_CONN_STR=$(terraform output -state=/mnt/tfstate/terraform.tfstate sql_conn_str)
echo $MY_SQL_DB_CONN_STR
echo "Terraform output read it"
sed -i -e "s/{{MY_SQL_DB_CONN_STRING}}/$MY_SQL_DB_CONN_STR/g" appsettings.json
echo "$(<appsettings.json)"
rm -r Migrations
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet tool restore
echo "starting EF migration"
dotnet ef migrations add InitialCreate
echo "starting database update "
dotnet ef database update

echo ".net core publish"
dotnet publish -o ./publish
cd ./publish

zip -r WebApp.zip .

az webapp deployment source config-zip -g azmonitor-$TARGET_ENV -n azmonitor-app-service-$TARGET_ENV --src WebApp.zip

echo "COMPLETED WEB APP DEPLOY"