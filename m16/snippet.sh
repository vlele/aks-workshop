#***************************************************************************************
## Objective: This module demonstrates the network policy in AKS. It creates a MySql Pod and a  MySql Client Pod. First we show 
## MySql Client Pod can connect to "MySql Pod" without any network policy applied. Then we apply "backend-policy-disallow.yaml" 
## to disallow any communication to "MySql Pod" and try connecting again. As expected it fails with error "ERROR 2003 (HY000)"
## Then we apply "backend-policy-allow.yaml" to allow communication from MySql Client Pod to "MySql Pod" and try connecting again.
#***************************************************************************************
## Prerequisites:cd ,..
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#    - Under .\aks\util\saved folder execute the commands in "create_aks_cluster.sh"  file 
## Assumptions: 
#	 	Assuming that the Cluster is already created in m1 module is going to be shared by all the modules	
#	 	Assuming that helm is installed in the local machine where 'kubectl' commands are being run	
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m16 module directory
cd ..\m16

Namespace="networkpolicy"

# Create and set context to "$namespace" namespace
kubectl create namespace $Namespace

# Create a Service Account 
kubectl create serviceaccount -n kube-system tiller

# Create a cluster role binding
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

#--> Configure Helm to use the tiller service account 
helm init --upgrade --service-account tiller

#--> Update Helm repo
helm repo update

# 1. Install install 
helm install stable/mysql --name my-special-installation --set mysqlPassword=password 

# 2. launch an Ubuntu pod
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il 
apt update
apt install wget
# Install the mysql client:
apt-get update && apt-get install mysql-client -y

# 3. Get root passwor: Run the below command in another PowerShell window
kubectl get secret my-special-installation-mysql -o jsonpath="{.data.mysql-root-password}"
#--> # Sample Output:
#--> # 		b2ZadzEzaGlvUw==
#--> # Go to the URL https://www.base64decode.org and decode the String received above. The decode output  --> ofZw13hioS

# 4. Connect using the mysql-client, then provide your password( ofZw13hioS ):
mysql -h my-special-installation-mysql -p
show databases;

# 5. Connect to MY SQL using the mysql cli, then provide your password:
mysql -h my-special-installation-mysql -p 

# 6. apply network policy
kubectl apply -f manifests/backend-policy-disallow.yaml

#7 This pod should not have been killed  
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il 
apt update
apt install wget
# Install the mysql client:
apt-get update && apt-get install mysql-client -y

# 7. Again, try to connect using the mysql-client and provide your password and this is disallowed
mysql -h my-special-installation-mysql -p
#--> # Sample Output:
#		ERROR 2003 (HY000): Can't connect to MySQL server on 'my-special-installation-mysql' (110)
kubectl apply -f manifests/backend-policy-allow.yaml
l
# 8. Connect using the mysql-client, then provide your password( ofZw13hioS ):
mysql -h my-special-installation-mysql -p
show databases;

#exit from the Ububtu
exit

# Cleanup Steps:
kubectl delete namespace $namespace