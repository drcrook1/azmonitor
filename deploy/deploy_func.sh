echo "Create blob container"

az storage container create --account-name azmonitor$TARGET_ENV --name outcontainer01 --auth-mode login

echo "Deploying Function code using Az commands"
cd ..
cd ./Src/Function

zip -r Function.zip .

az functionapp deployment source config-zip -g azmonitor-$TARGET_ENV -n azmonitor-function-$TARGET_ENV --src Function.zip
echo "COMPLETED FUNCTION APP DEPLOYS"