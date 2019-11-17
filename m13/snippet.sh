#***************************************************************************************
## Objective: This module demonstrates installing a MYSQl Pod using Helm in AKS and connecting it from another Pod in the same AKS. 
#***************************************************************************************
## Prerequisites:
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
## Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m13 module directory
cd ..\m13

$rg_name = "aks-class-new"
$cluster_name = "aks-class"
$location="eastus"
$namespace = "mysqlhelm"

# Create and set context to "$namespace" namespace
kubectl create namespace $namespace
kubectl config set-context $(kubectl config current-context) --namespace=$namespace
# Use the context
kubectl config use-context $(kubectl config current-context)
# Create a Service Account 
kubectl create serviceaccount -n kube-system tiller
# Create a cluster role binding
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#--> Configure Helm to use the tiller service account 
helm init --upgrade --service-account tiller
#--> Update Helm repo
helm repo update
# Below command not needed
#kubectl patch deploy -n kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' 

#-->  Install mysql 
#-->  helm del --purge my-special-installation
helm install stable/mysql --name my-special-installation --set mysqlPassword=password

#--> 1. launch an Ubuntu pod
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il
apt update
apt install wget

#--> 2. Install the mysql client:
apt-get update && apt-get install mysql-client -y

#--> # Get root password in another PowerShell Window.
kubectl get secret my-special-installation-mysql -o jsonpath="{.data.mysql-root-password}"
#--> # Sample Output:
#--> # 		MHlFU2lRMEEwSA==
#--> # Go to the URL https://www.base64decode.org and decode the String received above. The decode output  --> 0yESiQ0A0H

#--> 3. Connect using the mysql-client, then provide your password:
mysql -h my-special-installation-mysql -p
show databases;

#--> 4. 
#exit from the Ububtu

# Cleanup Steps:
helm list
#--> # Sample Output:
#--> # NAME             		REVISION   UPDATED                    STATUS    CHART           NAMESPACE
#--> # my-special-installation  1          Mon Oct 14 03:38:19 2019   DEPLOYED  mysql-1.4.0     mysqlhelm

helm del --purge my-special-installation
kubectl delete namespace $namespace
