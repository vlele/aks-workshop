#***************************************************************************************
## Objective: This module demonstrates the network policy in AKS. It creates a MySql Pod and a  MySql Client Pod. First we show 
## Note: This demo is not verifiable due to "https://github.com/kubernetes/kubernetes/issues/90077" where it says "No matches for kind "Ingress" in 
## version "networking.k8s.io/v1". 
#***************************************************************************************

NAMESPACE=mysqlhelm
kubectl create namespace $NAMESPACE
MYSQL_HELM_PACKAGE_NAME="my-release"

#note -  assuming this module is a continuation of m13 
#--> Go to m16 module directory

cd ../m16

# apply network policy
kubectl apply -f manifests/backend-policy-disallow.yaml
kubectl describe networkpolicy.networking.k8s.io/backend-policy
# switch to ubuntu ssh and reconnect to the my sql instance 

kubectl apply -f manifests/backend-policy-allow.yaml
kubectl describe networkpolicy.networking.k8s.io/backend-policy

# Cleanup Steps:
#helm del --purge MYSQL_HELM_PACKAGE_NAME    <-- This will work in helm version 2
helm uninstall $MYSQL_HELM_PACKAGE_NAME
kubectl delete namespace $NAMESPACE
