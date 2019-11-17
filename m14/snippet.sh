#***************************************************************************************
## Objective: This module demonstrates the use of ServiceAccount, ClusterRole and ClusterRoleBinding to allow/disallow access to API Server from within a Pod in AKS 
#***************************************************************************************
## Prerequisites:
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
## Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m14 module directory
cd ..\m14


# Create and set context to "$namespace" namespace
kubectl create namespace "rbac-apiserver"


# Create a Service Account 
# 1. Execute the Command below to perform the following steps:
# 	- Create a custom service account foo
# 	- Create a role “service-reader” that only has read permissions on services resource 
# 	- Bind the “service-reader” role to foo
# 	- create a Pod with the custom service principle foo 

kubectl apply -f manifests/curl-custom-sa.yaml

# Open a bash shell inside the Pod
kubectl exec curl-custom-sa -c main -it bash

# 2. Execute the below Commands inside the pod and finally run an API command

token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
hostname=kubernetes.default.svc

curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/services
#   Note:  The output should contain HTTP/1.1 200 OK
  
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/secrets
#   Note:  The output should contain HTTP/1.1 200 OK
exit

# 3. Edit the ClusterRole in the file '.\k8\curl-custom-sa.yaml' and  drop the permissions for the "services" in the following 
# line(no.14) and execute the commands again, 
# 	- Original Line:  resources: ["services", "endpoints", "pods", "secrets"]
# 	- Updated Line:   resources: ["endpoints", "pods", "secrets"]  

#--> Illustrate the updated yaml with changed permissions
kubectl apply -f manifests/curl-custom-sa.updated.yaml

# Open a bash shell inside the Pod
kubectl exec curl-custom-sa -c main -it bash

# 4. Execute the below Commands inside the pod and run an API command
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
hostname=kubernetes.default.svc

curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/services
#   Note:  The output should contain HTTP/1.1 403 Forbidden 
  
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization:Bearer $token" https://$hostname:443/api/v1/namespaces/default/secrets
#   Note:  The output should contain HTTP/1.1 200 OK
exit

# Cleanup Steps:
kubectl delete namespace "rbac-apiserver"

