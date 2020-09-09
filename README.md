# Deployment Walkthrough Video Script

## Tactical: How to Execute
1.  What dependencies do you need installed
    1.  Installing Docker
    2.  Having an Azure Subscription
    3.  Git or Download as zip (git preffered)
        1.  Git for Windows, Mac or Ubuntu
2. How to clone the repo from CLI
3. Modify dev.env
4. Running the build_deploy.cmd

## Strategic: How it Works
1.  Folder Structure Composition
2.  DockerFile
3.  deploy folder in depth 
    1.  deploy_all.sh
        1.  terraform
            1.  Infrastructure & connectivity
        2.  function
        3.  app
    2. Terraform Dive
       1. terraform_deploy.sh
          1. exporting TF_VAR_
          2. init, plan & apply
          3. Talk about (remote) state & volume mounting
       2. Breif overview of .tf files
    3. deploy_func.sh
       1. zip package
       2. deploy
    4. deploy_app.sh
       1. terraform output
       2. firewall to open universe
       3. code first migration
       4. dotnet publish
       5. zip
       6. deploy
4. Completely Deployed
   1. Show Azure Portal
   2. Show Web App & How to navigate to app url
      1. enter a todo or two
   3. Show App Insights Main Page

END HERE.
