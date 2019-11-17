#***************************************************************************************
##  Objective: This module demonstrates the programmatic access of our K8S environment in AKS. It often requires access control from with in the K8S services themselves, and this 
##  is often accomplished by a service account. When we run this sample, the following things happen:
##  - We'll install the Helm application management environment, which requires a local client (helm), and which will leverage our local credentials to install a management 
##  application into K8S.  
##  - The helm client does not, however, create the required cluster level roles and role bindings or service account to establish proper communications with the K8S environment, 
##  so we'll do that.
#***************************************************************************************
##   Prerequisites:
##	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
##   - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
##	 Assumptions: 
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run and then we can install RBACresources and the Kubernetes service side component 
#       in our AKS system.  Get the helm binary for your environment here:
#		MacOSX: https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-darwin-amd64.tar.gz
#		Linux:  https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
#		Windows:https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-windows-amd64.zip
## 	 Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m11 module directory
cd ..\m11

NAMESPACE="progk8access"

# Create and set context to "$namespace" namespace
kubectl create namespace $NAMESPACE

# Install the RBAC configuration for tiller so that it has the appropriate access, and initialize helm system:
kubectl create -f manifests/helm-rbac.yaml
helm init --service-account=tiller

# Create a new default workspace by enabling the add-on for our cluster:

az aks enable-addons -a monitoring -n $CLUSTER_NAME -g $RESOURCE_GROUP_NAME


# Once installed, we should be able to see that the monitoring agent has been installed in the kube-system namespace:
kubectl get ds omsagent --namespace=kube-system

# To view output, we need to use the Azure web portal:
#	- In the resource pane at the far left  select the "All Services" panel, and search for Kubernetes.
#	- Select the Kubernetes services, and then select your test cluster (myAKSCluster if you used the same name in the course).
#	- Select Monitoring, and we can sort through log and monitoring data from nodes to individual containers. 
# Note: It may take up to 15 minutes for data collection to be displayed as the services may need to synchronize first.

# To add metrics to our Kubernetes environment, we'll use Helm to install Prometheus.
helm install --name promaks --set server.persistentVolume.storageClass=default stable/prometheus

# Once Prometheus is installed, and once it completes it's launch process (which may take a few minutes), we can locally expose the Prometheus UI to look at some of the captured metrics.  We'll do this by forwarding the UI's port to our local machine as the UI application doesn't have any access control defined.

kubectl get pods -n $namespace -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}"
pod_prometheus="promaks-prometheus-server-7b84b44949-v9zv7"

kubectl -n $namespace  port-forward $pod_prometheus 9090

# Once the portforward is running, we can point a web browser at:
http://localhost:9090

# Look to see what metrics are being gathered.
> Copy the "container_cpu_usage_seconds_total" parameter --> paste it into the "Textbox" Prometheus UI --> click "Execute"

# And we can also generate a little load if we'd like:
kubectl apply -f manifests/hostname.yml

> Edit "curl.yaml" file for correct "namespace: progk8access". 
kubectl apply -f manifests/curl.yml
kubectl exec -it $(kubectl get pod -l app=curl -o jsonpath="{.items[0].metadata.name}") sh 
# At the command prompt inside the pod execute the below command
# curl -o - http://hostname/version/ 

# Cleanup Steps:
helm del --purge promaks
kubectl delete -f manifests/curl.yml
kubectl delete -f manifests/hostname.yml
az aks disable-addons --addons monitoring -n $cluster_name -g $rg_name 
kubectl delete namespace $namespace


