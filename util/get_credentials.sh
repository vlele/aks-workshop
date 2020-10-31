# Cluster #1  Advanced VNET
RESOURCE_GROUP_NAME=vlakstest5e_RG
CLUSTER_NAME=vlakstest5e
LOCATION=eastus2
MC_RESOURCE_GROUP_NAME=MC_vlakstest5_RG_vlakstest5_eastus2
SUBSCRIPTION_ID="0d4f44f5-e032-49de-ba6c-86dcf4201a31"

# Cluster #2  Advanced VNET
RESOURCE_GROUP_NAME=vlakstest5e_RG
CLUSTER_NAME=vlakstest5e
LOCATION=eastus
MC_RESOURCE_GROUP_NAME=MC_vlakstest5e_RG_vlakstest5e_eastus




# Get Credentials 
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME  --name $CLUSTER_NAME  --overwrite

# ClusterRoleBinding must be created before you can correctly access the dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

#--> Assign the "<tenant-id>" to a variable
AZURE_TENANT_ID="f32b97f0-efb8-4bc3-91ee-18a6e5f635c9"
#--> Assign the "<sp-id>" to a variable
AZURE_CLIENT_ID="4460bc9b-305b-45f7-8f39-c42fab2f02c7"
#--> Assign the "<sp-pwd>" to a variable
AZURE_CLIENT_SECRET="ca4-8b76-4c75-95dd-33d67704dfbd"
#--> Assign the "<subscription-id>" to a variable
AZURE_SUBSCRIPTION_ID="0d4f44f5-e032-49de-ba6c-86dcf4201a31"
