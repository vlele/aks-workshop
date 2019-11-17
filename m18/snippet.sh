##***************************************************************************************
## Objective: This module demonstrates the VIRTUAL KUBELET ACI in AKS. 
##***************************************************************************************
## Prerequisites:
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
## Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m18 module directory
cd ..\m18

namespace="aciaks"

# Create and set context to "$namespace" namespace
kubectl create namespace $namespace

#--> Register providers needed for AKS cluster
az provider register -n Microsoft.ContainerInstance
az provider register -n Microsoft.ContainerService

#--> AKS cluster is RBAC-enabled, we must create a service account and role binding for use with Tiller. 
kubectl apply -f manifests/rbac-virtual-kubelet.yaml

#--> Check all pods in AKS cluster 
kubectl get pods -o wide --all-namespaces 

#-->Install the ACI connector for both OS types 
az aks install-connector -g $RESOURCE_GROUP_NAME -n $CLUSTER_NAME --connector-name virtual-kubelet --os-type Both        


#--> Check all pods again and see that two pods with names starting with "virtual-kubelet-..." exists in AKS cluster 
kubectl get pods -o wide 
#--> Sample Output:
#--> NAMESPACE     NAME
#--> aciaks        virtual-kubelet-linux-eastus-virtual-kubelet-for-aks-56474jgfg5
#--> aciaks        virtual-kubelet-windows-eastus-virtual-kubelet-for-aks-575nrs52

#--> List all nodes (notice the ACI nodes)
kubectl get nodes 
#--> Sample Output:
#--> NAME                                             STATUS
#--> ...
#--> virtual-kubelet-virtual-kubelet-linux-eastus     Ready
#--> virtual-kubelet-virtual-kubelet-windows-eastus   Ready

#--> Copy above windows virtual node name and update(if needed)"..\m18\manifests\virtual-kubelet-windows-phpiis-ltsc2016.yaml" file at, 
#-->   nodeSelector:
#-->         kubernetes.io/hostname: virtual-kubelet-virtual-kubelet-windows-eastus

#--> Deploy pods into linux virtual kubelet
kubectl create -f manifests/virtual-kubelet-linux-hello-world.yaml
kubectl get pods -o wide
#--> Sample Output:
#--> NAME       READY   STATUS    RESTARTS   AGE     IP               NODE
#--> helloworld  1/1     Running   0          3m27s   52.188.181.181   virtual-kubelet-virtual-kubelet-linux-eastus

> Create URL for "hello-world" application http://52.188.181.181 and browse.It should show msg "Welcome to Azure Container Instances!" 

#--> Deploy pods into windows virtual kubelet. This step will take 14-15 mins
kubectl create -f manifests/virtual-kubelet-windows-phpiis-ltsc2016.yaml
kubectl get pods -o wide
#--> Sample Output:
#--> NAME                           READY STATUS RESTARTS  AGE   IP            NODE
#--> ... 
#--> php-iislatest2-5594c95468-25cln 1/1 Running  0        14m   40.90.243.205  virtual-kubelet-virtual-kubelet-windows-eastus

> Create URL for "phpiis" application http://40.90.243.205 and browse.It should show the page with PHP related server data 

# Cleanup Steps:
helm del --purge virtual-kubelet-linux-eastus2
helm del --purge virtual-kubelet-windows-eastus2
kubectl delete namespace $namespace