
# Video Documentation
## English
### Introduction
[![](http://img.youtube.com/vi/Mrnu2R8lk3s/0.jpg)](http://www.youtube.com/watch?v=Mrnu2R8lk3s "Introduction")
### How to Deploy
[![](http://img.youtube.com/vi/4LQ-8zOpRaE/0.jpg)](http://www.youtube.com/watch?v=4LQ-8zOpRaE "Deployment")


# Video Scripts

NOTES: 
Keep the high level walk through from accessibility perspective.
Add to "Monitoring Community Repo"
Add to FTA Private Repo via link.
Add to FTA Public Repo


## Tactical: How to Execute
INTROS!
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

# Usecase & Usage Demo
INTROS!
0.  We had a real customer with similar problem space, but we will talk about contoso instead.
1.  Contoso is building a distributed ML Inference System.
    1.  Have parts a, b & c with human intervention between b & c.  Running on different infra in different languages.
    2.  end result measured at C shows a 45% error.
    3.  How do we optimize the model to reduce error rates?
    4.  Predictions give a confidence or output across multiple categories.
    5.  We can measure human intervention corrections
2. Solution
   1. Distributed Tracing allows us to see the dependencies and relations in communications for a single thread through a distributed system allowing for the logging and relation of specific meta data.
   2. In this case we log "data drop location, flux capacitance & other fake data".  In the real scenario, confidence scores, data locations and other pertinent information at each stage is recorded.
   3. This allows us to understand where in the system issues are happening as well as gather required input/output pairs to prioritize for curation into the ML training process therefor optimizing our models.
3. Show a demo of finding a flux capacitance less than something and locating the blob file associated to it that originated the request.
   1. Show App Insights, and Kusto Query on the customevent where customdimensions.fluxcapacitance is less than 1.  Find a request, then search on operation id to find the chain and show the blob location where we can grab the source data which should now be used for ML Training.

4.  As a stretch goal we wanted to make sure we adhered to the W3C standard and this is showcased in both .net core & node.js.  We did this because:
    1.  Azure is moving to the W3C standard for traceability and therefor if we implement it, we can inheret following the dependency chain if it interacts with other services which are Azure based and W3C compliant for distributed tracing.
