##***************************************************************************************
## Objective: This module demonstrates the VIRTUAL KUBELET ACI in AKS. 
##***************************************************************************************

#--> Go to m18 module directory
cd ../m18

NAMESPACE="aciaks"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

#--> Register providers needed for AKS cluster
az provider register -n Microsoft.ContainerInstance
az provider register -n Microsoft.ContainerService

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests/rbac-virtual-kubelet.yaml

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#--> Deploy Open Service Broker for Azure
> ./install-aciaks.sh   <-- Please run the "./install-aciaks.sh" as it is

#--> List all nodes (notice the ACI nodes)
kubectl get nodes 

#--> Deploy pods into linux virtual kubelet
kubectl apply -f manifests/virtual-kubelet-linux-hello-world.yaml

kubectl get pods

# Cleanup Steps:
helm del --purge virtual-kubelet-linux-eastus2
helm del --purge virtual-kubelet-windows-eastus2
kubectl delete namespace $NAMESPACE
