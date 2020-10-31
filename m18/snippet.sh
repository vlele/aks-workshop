##***************************************************************************************
## Objective: This module demonstrates the VIRTUAL KUBELET ACI in AKS. 
##***************************************************************************************

#--> Go to m18 module directory
cd ../m18

# Follow the steps in the article below to create a new cluster
# https://docs.microsoft.com/en-us/azure/aks/virtual-nodes-portal

NAMESPACE="aciaks"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

#--> Register providers needed for AKS cluster
az provider register -n Microsoft.ContainerInstance
az provider register -n Microsoft.ContainerService

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#--> List all nodes (notice the ACI nodes)
kubectl get nodes 

#--> Deploy pods into linux virtual kubelet
kubectl apply -f manifests/virtual-kubelet-linux-hello-world.yaml

kubectl get pods

# Cleanup Steps:
kubectl delete namespace $NAMESPACE