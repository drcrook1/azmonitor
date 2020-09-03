echo "Deploying Function code using Az commands"
cd ..
cd ./Src/Function

zip -r Function.zip .

az functionapp deployment source config-zip -g azmonitor-dacrook01 -n azmonitor-function-dacrook01 --src Function.zip