#Programatic access of our Kubernetes environment often requires access control from _within_ the Kubernetes services themselves, and this access is often accomplished by a service account resource.
#In this example we'll install the Helm application management environment, which requires a local client (helm), and which will leverage our local credentials to install a management application into Kubernetes.  The helm client does not, however, create the required cluster level roles and role bindings or service account to establish proper communications with the kubernetes enviornment, so we'll do that.
#First we need helm installed as a client on our workstation, and then we can install RBACresources and the Kubernetes service side component in our AKS system.  Get the helm binary for your enviornment here:
#MacOSX:
#https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-darwin-amd64.tar.gz
#Linux:
#https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
#Windows:
#https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-windows-amd64.zip

#Then we can install the RBAC configuration for tiller so that it has the appropriate access, and lastly we can initialze our helm system:

kubectl create -f manifests/helm-rbac.yaml
helm init --service-account=tiller


#You can create a new default workspace by enabling the add-on for our cluster:
# ClusterDetails
az aks enable-addons -a monitoring -n $NAME -g $RG

#Once installed, we should be able to see that the monitoring agent has been installed in the kube-system namespace:
kubectl get ds omsagent --namespace=kube-system

#To view output, we need to use the Azure web portal:

#In the resource pane at the far left (it may be collapsed, in which case expand it), select the "All Services" panel, and search for Kubernetes.

#Select the Kubernetes services, and then select your test cluster (myAKSCluster if you used the same name in the course).

#Then select Monitoring, and we can sort through log and monitoring data from nodes to individual contaiers. Note it may take up to 15 minutes for data collection to be displayed as the services may need to synchronize first.

#To add metrics to our Kubernetes enviornment, we'll use Helm to install Prometheus.

helm install --name promaks --set server.persistentVolume.storageClass=default stable/prometheus

#Once Prometheus is installed, and once it completes it's launch process (which may take a few minutes), we can locally expose the Prometheus UI to look at some of the captured metircs.  We'll do this by forwarding the UI's port to our local machine as the UI application doesn't have any access control defined.

kubectl --namespace prod port-forward $(kubectl get pods --namespace prod -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}") 9090 &

#Once the portforward is working, we can point a web browser at:

http://localhost:9090

#look to see what metrics are being gathered.

container_cpu_usage_seconds_total

#And we can also generate a little load if we'd like:


kubectl apply -f manifests/hostname.yml
kubectl apply -f manifests/curl.yml

# change to default namespace
kubectl exec -it $(kubectl get pod -l app=curl -o jsonpath={.items..metadata.name}) -- \
sh -c 'while [[ true ]]; do curl -o - http://hostname/version/ ; done'


