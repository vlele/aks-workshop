#***************************************************************************************
## Objective: This module demonstrates the OSBA in AKS. When you run this sample, the following things happen:
#***************************************************************************************

#--> Go to m17 module directory
cd ../m17

NAMESPACE="osba"
NAMESPACE_CATALOG="catalog"
kubectl create namespace $NAMESPACE
kubectl create namespace $NAMESPACE_CATALOG

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests/clusterrole-binding-sa.yaml

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#--> Check that we have a Service Account("tiller") in the cluster. 
kubectl get serviceAccounts --all-namespaces

#--> Configure Helm to use the tiller service account 
#helm init --upgrade --service-account tiller <-- This will work in helm version 2

#--> Update Helm repo
helm repo update

#--> Get service principal that has rights on the subscription we want to create resources
#--> OSBA namespace needs to be unique 

#-->Sample output: 
#--> Changing "osba-cosmos-demo" to a valid URI of "http://osba-cosmos-demo", which is the required format ...
#-->  AppId    DisplayName             Name            Password    Tenant
#--> -------- ---------------  ----------------------  --------  -----------
#--> <sp-id>  osba-cosmos-demo  http://osba-cosmos-demo  <sp-pwd>  <tenant-id>

#--> Add the Service Catalog helm repo to helm 
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

#--> Install svc-cat/catalog
helm install svc-cat/catalog --name-template catalog --namespace $NAMESPACE_CATALOG --set apiserver.storage.etcd.persistence.enabled=true --set apiserver.healthcheck.enabled=false --set controllerManager.healthcheck.enabled=false --set apiserver.verbosity=2 --set controllerManager.verbosity=2

#--> Check the catalog installation. This is going to take "2-3" mins time
kubectl get pods -n catalog -w

#--> Press "Ctrl+C" to break the watch
kubectl get pods -n catalog

#--> Deploy Open Service Broker for Azure. First, we need to add the repo
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

#--> Execute the "helper-sp-params.sh" and create a service principal that has rights on the subscription to create resources and initialize the variables  
> . helper-sp-params.sh   <-- Please run the ". helper-sp-params.sh" as it is

#--> Deploy Open Service Broker for Azure
> ./install-broker.sh   <-- Please run the "./install-broker.sh" as it is

#--> Check the catalog installation.It takes "2-3" mins. You may see status changing "CrashLoopBackOff/Error/Running", that's ok
kubectl get pods -n osba -w

#--> Edit the "mongodb-service-instance.yaml" file for correct "resourceGroup: aks-class-new". Deploy Resources with OSBA. Here we are deploying "azure-mongodb-instance"
kubectl create -f manifests/mongodb-service-instance.yaml
#--> Verify: A CosmosDB is created in the "$rg_name" resource group

kubectl get serviceinstance -w

kubectl get serviceinstance 
kubectl create -f manifests/azure-mongodb-binding.yaml

#--> Deploy an application which writes to azure cosmos mongo database every 30 seconds. 
kubectl apply -f manifests/osba-cosmos-mongodb-demo.yaml


# Cleanup Steps:
kubectl delete -f manifests/osba-cosmos-mongodb-demo.yaml
kubectl delete -f manifests/azure-mongodb-binding.yaml
kubectl delete -f manifests/clusterrole-binding-sa.yaml
#-->  The following action will delete the CosmosDB in Azure Portal as well
kubectl delete -f manifests/mongodb-service-instance.yaml

helm uninstall $NAMESPACE
helm uninstall $NAMESPACE_CATALOG
kubectl delete namespace $NAMESPACE


 



