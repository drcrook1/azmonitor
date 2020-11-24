docker stop azmonitordeploy
docker rm azmonitordeploy
docker build -t azmonitordeploy .
docker volume rm terraform
docker volume create --name terraform
docker run -it --name azmonitordeploy -v terraform:/mnt/tfstate --env-file ./dev.env azmonitordeploy