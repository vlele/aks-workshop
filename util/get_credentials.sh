# Cluster #1  Advanced VNET
RESOURCE_GROUP_NAME=XXXX
CLUSTER_NAME=XXXX
LOCATION=XXXX
MC_RESOURCE_GROUP_NAME=XXXX
SUBSCRIPTION_ID=XXXX


# Get Credentials 
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME  --name $CLUSTER_NAME  --overwrite

# ClusterRoleBinding must be created before you can correctly access the dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

