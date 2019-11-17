#***************************************************************************************
##  Objective: This module demonstrates the usage of Azure Identity in conjunction with K8 primitives. AAD Pod Identity enables K8 
##  applications to access cloud resources securely with Azure Active Directory (AAD). Using K8 primitives, administrators configure 
##  identities and bindings to match pods. Then without any code modifications, our containerized applications can leverage any resource 
##  in the cloud that depends on AAD as an identity provider.
#***************************************************************************************
##  Prerequisites:
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
##	Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## 	Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m15 module directory
cd ..\m15

namespace="aadpodidentity"

# Create and set context to "$namespace" namespace
kubectl create namespace $namespace

# 1. Create the Deployment, AAD Pod Identity consists of the Managed Identity Controller (MIC) deployment, the Node Managed Identity (NMI) daemon set, and several standard and custom resources
kubectl apply -f manifests/infra/deployment-rbac.yaml

# 2. Create an Azure Identity
PrincipalId=(az identity create --name demo-aad1 --resource-group MC_RESOURCE_GROUP_NAME --query 'principalId' -o tsv)
PrincipalId=fd601fb5-b0ed-4744-af4e-2bdc475ad9da
#3 check if az identity got created 
az identity list

# Wait for some time(2-3 mins) and then execute the below command
az role assignment create --role Reader --assignee $PrincipalId --scope /subscriptions/0d4f44f5-e032-49de-ba6c-86dcf4201a31/resourcegroups/$MC_RESOURCE_GROUP_NAME

# 3. Pick up the “clientId” from the output of below command
az identity show -n demo-aad1 -g $MC_RESOURCE_GROUP_NAME

# Edit the "manifests/demo/deployment.yaml" and "manifests/demo/aadpodidentity.yaml" files and provide "$client_id" copied from above step
# 4. Install the Azure Pod Identity, Binding and Deploy a Pod
kubectl apply -f manifests/demo/aadpodidentity.yaml
kubectl apply -f manifests/demo/aadpodidentitybinding.yaml
kubectl apply -f manifests/demo/deployment.yaml

kubectl get pods

# 5. Check the Logs for the results: Below command will show the message on VMs: msg="succesfully made GET on instance metadata". "compute":{"location":"eastus","name":"<VM Name>","offer":"aks","osType":"Linux"
kubectl logs <demo-your-pod-specific>

# Cleanup Steps:
kubectl delete namespace $namespace

