#***************************************************************************************
## Objective: This module demonstrates installing a MYSQl Pod using Helm in AKS and connecting it from another Pod in the same AKS. 
#***************************************************************************************

#note: default helm install name 

cd ../m13

NAMESPACE=mysqlhelm
kubectl create namespace $NAMESPACE
MYSQL_HELM_PACKAGE_NAME="my-release"
# Create and set context to "$namespace" namespace

# Create a Service Account 
kubectl create serviceaccount -n kube-system tiller
# Create a cluster role binding
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

#--> Configure Helm to use the tiller service account 
<<<<<<< HEAD
helm init --upgrade --service-account tiller
    #--> Update Helm repo
helm repo add stable https://kubernetes-charts.storage.googleapis.com/helm install  stable/mysql  --generate-name
=======
#helm init --upgrade --service-account tiller   <-- This will work in helm version 2
#--> Update Helm repo
helm repo update

>>>>>>> 9b69b02d238b9390e9c92944a798a5c5274f6b0a
#-->  Install mysql 
helm install --name-template $MYSQL_HELM_PACKAGE_NAME stable/mysql
<<<<<<< HEAD
#--> 1. launch an Ubuntu pod
=======

#--> 1. launch an Ubuntu pod, in a PowerShell Window
>>>>>>> 9b69b02d238b9390e9c92944a798a5c5274f6b0a
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il
apt update
apt install wget

#--> 2. Install the mysql client:
apt-get update && apt-get install mysql-client -y

#--> Now switch terminal abd obtain the mysql password 
kubectl get secret my-release-mysql -o jsonpath="{.data.mysql-root-password}"
#--> Be sure to decode it from base64
#--> # Go to the URL https://www.base64decode.org and decode the String received above. The decode output  --> 0yESiQ0A0H

#-->  Also print the same of the service by typing svcs"
#--> . Connect using the mysql-client, then provide your password:

svcs # note the name of my sql service
mysql -h <Your-my-sql-service-name> -p
#mysql -h my-release-mysql -p
show databases;

#*don't* exit from the Ububtu - jump to network policy module 

# Cleanup Steps
helm list
helm uninstall  < name>

# don't cleanup until module #16