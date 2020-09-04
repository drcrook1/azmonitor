echo "Create blob container"

//az storage container create --account-name azmonitordacrook01 --name outcontainer01 --auth-mode login

echo "Deploying Function code using Az commands"
cd ..
cd ./Src/Function

zip -r Function.zip .

az functionapp deployment source config-zip -g azmonitor-dacrook01 -n azmonitor-function-dacrook01 --src Function.zip