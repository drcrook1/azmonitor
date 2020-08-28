docker stop azmonitordeploy
docker rm azmonitordeploy
docker build -t azmonitordeploy .
docker run -it --name azmonitordeploy --env-file ./dev.env azmonitordeploy