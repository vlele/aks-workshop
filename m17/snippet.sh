#***************************************************************************************
## Objective: This module demonstrates the OSBA in AKS. When you run this sample, the following things happen:
##   - CosmosB / MongodDB instance are created in a resource group
##   - A Kubernetes secret is created with the MongoDB connection string.
##   - A pod is started that consumes the secret, runs the container in it which creates a database named "hello-osba" and writes 
##     a document to the DB every 30 seconds.
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

#--> Go to m17 module directory
cd ..\m17

namespace="osba"

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests/clusterrole-binding-sa.yaml

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#--> Check that we have a Service Account("tiller") in the cluster. 
kubectl get serviceAccounts --all-namespaces

#--> Configure Helm to use the tiller service account 
helm init --upgrade --service-account tiller

#--> Update Helm repo
helm repo update

#--> Get service principal that has rights on the subscription we want to create resources
#--> OSBA namespace needs to be unique 

#-->Sample output: 
#--> Changing "osba-cosmos-demo" to a valid URI of "http://osba-cosmos-demo", which is the required format ...
#-->  AppId    DisplayName             Name            Password    Tenant
#--> -------- ---------------  ----------------------  --------  -----------
#--> <sp-id>  osba-cosmos-demo  http://osba-cosmos-demo  <sp-pwd>  <tenant-id>

#--> Assign the "<tenant-id>" to a variable
AZURE_TENANT_ID="f32b97f0-efb8-4bc3-91ee-18a6e5f635c9"
#--> Assign the "<sp-id>" to a variable
AZURE_CLIENT_ID="4460bc9b-305b-45f7-8f39-c42fab2f02c7"
#--> Assign the "<sp-pwd>" to a variable
AZURE_CLIENT_SECRET="ca4-8b76-4c75-95dd-33d67704dfbd"
#--> Assign the "<subscription-id>" to a variable
AZURE_SUBSCRIPTION_ID="0d4f44f5-e032-49de-ba6c-86dcf4201a31"

#--> Add the Service Catalog helm repo to helm 
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

#--> Install svc-cat/catalog
helm install svc-cat/catalog --name catalog --namespace catalog --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2

#--> Check the catalog installation. This is going to take "2-3" mins time
kubectl get pods -n catalog -w
#--> Press "Ctrl+C" to break the watch
kubectl get pods -n catalog

#--> Deploy Open Service Broker for Azure. First, we need to add the repo
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

#--> Deploy Open Service Broker for Azure
helm install azure/open-service-broker-azure --name osba --namespace osba --set azure.subscriptionId=$env:AZURE_SUBSCRIPTION_ID --set azure.tenantId=$env:AZURE_TENANT_ID --set azure.clientId=$env:AZURE_CLIENT_ID --set azure.clientSecret=$env:AZURE_CLIENT_SECRET

#--> Check the catalog installation.It takes "2-3" mins. You may see status changing "CrashLoopBackOff/Error/Running", that's ok
kubectl get pods -n osba -w

#--> Edit the "mongodb-service-instance.yaml" file for correct "resourceGroup: aks-class-new". Deploy Resources with OSBA. Here we are deploying "azure-mongodb-instance"
kubectl create -f manifests\mongodb-service-instance.yaml
#--> Verify: A CosmosDB is created in the "$rg_name" resource group

kubectl get serviceinstance -w
#--> Take a break till the "STATUS" is ready. It will take 8-9 mins.
kubectl get serviceinstance 
#--> Sample output: 
#--> NAME                     CLASS                                              PLAN      STATUS   AGE
#--> azure-mongodb-instance   ClusterServiceClass/azure-cosmosdb-mongo-account   account   Ready    16m

#--> Edit "azure-mongodb-binding.yaml" file for correct "namespace: osba".  Create the binding that creates a secret with azure cosmos mongo database connection details.
kubectl create -f manifests\azure-mongodb-binding.yaml

#--> Deploy an application which writes to azure cosmos mongo database every 30 seconds. 
kubectl apply -f manifests\osba-cosmos-mongodb-demo.yaml


#--> Demo Verification Steps: 
#-->  Check the CosmosDB Collections growing in VSCode or in Azure Portal

# Cleanup Steps:
kubectl delete -f manifests\osba-cosmos-mongodb-demo.yaml
kubectl delete -f manifests\azure-mongodb-binding.yaml
#-->  The following action will delete the CosmosDB in Azure Portal as well
kubectl delete -f manifests\mongodb-service-instance.yaml
helm del --purge catalog
helm del --purge osba
kubectl delete namespace $namespace
kubectl delete namespace catalog


 



