######################################
#       START SECTION 0              #
#       BASIC DEPENDENCIES           #
######################################
FROM ubuntu:18.04

RUN apt-get clean -y
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install wget gnupg curl unzip jq apt-transport-https dos2unix -y

######################################
#       START SECTION 1              #
#       INSTALL TERRAFORM            #
######################################
ENV TERRAFORM_VERSION="0.12.23"
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
RUN mv terraform /bin

######################################
#       START SECTION 2              #
#       INSTALL AZURE CLI            #
######################################
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash


######################################
#       START SECTION 2              #
#       INSTALL AZURE FUNCTION       #
#       CORE TOOLS                   #
######################################
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update -y
RUN apt-get install azure-functions-core-tools-3 -y


######################################
#       START SECTION                #
#       INSTALL KUBECTL              #
######################################
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install kubectl -y

######################################
#       START SECTION                #
#       INSTALL HELM                 #
######################################
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

######################################
#       START SECTION 3              #
#       ADD TO PATH                  #
######################################
ENV PATH="/bin:${PATH}"

######################################
#       START SECTION 4              #
#       COPY DEPLOY CODES            #
######################################
COPY . /app

######################################
#       START SECTION 5              #
#       dos2Unix Everything          #
######################################
RUN find /app/deploy -type f -print0 | xargs -0 -n 1 -P 4 dos2unix 

######################################
#       START SECTION 6              #
#       RUN COMMAND                  #
######################################
WORKDIR /app/deploy
CMD ["/bin/bash", "/app/deploy/deploy_all.sh"]