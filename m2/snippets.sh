 # ***************************************************************************************
 #   Objective: This module provides the core concepts(PODS) of Kubernetes in Azure. 
 # ***************************************************************************************
##   Prerequisites:
#         	under utils \ create_aks_cluster.sh 
#       Last refreshed: 14/11/2019

# Create namespace "concepts"
kubectl create namespace concepts

# Set context to "concepts"
kubectl config set-context $(kubectl config current-context) --namespace=concepts

# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Create a pod (imperative)
kubectl run --generator=run-pod/v1 kuard --image=gcr.io/kuar-demo/kuard-amd64:1

#--> Create a pod (declarative)
kubectl apply -f manifests/kuard-pod.yml

kubectl get all 

# Export the YAM 
# Command Format: "kubectl get <resource> -o yaml --export=true". Example given below
kubectl get pod kuard-5c8c4499d4-bghq7  -o yaml --export=true &> kuard-5c8c4499d4-bghq7.yaml
 
# Show the "kuard-b75468d67-vm59n.yaml" YAML file 

#--> Proxy to the pod and load in the browser 
kubectl port-forward kuard 8080:8080
# Browse http://127.0.0.1:8080 and see the details in UI


#--> Start the proxy and show the api
kubectl proxy
# http://127.0.0.1:8001/api/v1/namespaces/concepts/pods


# Delete kuard 

#--> Delete kuard and add health endpoints
#--> Port forward and set the fail mode
#--> 

k delete deployment kuard
k delete pods --all
k apply -f manifests/kuard-pod-health.yaml

k port-forward kuard 8080:8080

#--> in another window show the constainer restarts
k get pods --watch 

#--> k delete kuard 

#--> Show volume mount
#--> Create a pod, port forward, explore the file system  
k apply -f manifests/kuard-pod-vol.yaml
kubectl port-forward kuard 8080:8080

# Browse http://127.0.0.1:8080 and show below items
# Cache 
# Persistent NFS, iSCSI
# Mouting host file system hostPath /var/lib/kuard 
# Cloud Provider 

#--> Exec into into the pod bash shell 
kubectl exec -it kuard ash
~ cd var 
~ ls
~ exit

#--> Show resource quotas, port forward, alloc
k delete pod --all
k apply -f manifests/kuard-pod-reslim.yaml
kubectl port-forward kuard 8080:8080

#--> In another windows watch the pods ( Show OOMKilled)
k get pods --watch 

# Browse http://127.0.0.1:8080 and allocate memory 500MB ( beyond the limit) using the UI
# this should fail the container. Check the watch window.

# Cleanup 
k delete pod --all
k delete deployment kuard 
kubectl delete namespace concepts