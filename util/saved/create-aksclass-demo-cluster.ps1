#Create the aksclass-demo Cluster which will be used for all the Demos from m1 to m12 modules
#Please pay attention to the region and AKS version numbers.  Not all regions support all modules#

Param 
(    
	[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] 
	[String] 
	$location,

	[String] 
	$version="1.11.5"
) 
Write-Host "location : " $location
Write-Host "version : " $version 

IF ($location -eq 'help') {
	echo "This PS Script file is used for for creating an AKS Cluster.Execute '.\az-basic-cmd.bat' batch file first."
	echo "Example: .\create-aksclass-demo-cluster.ps1 <location>, <version>"
	echo "Please use location as 'East US'/'Central US'/'West US 2'/'West Europe'/'Canada Central'/'Canada East region'"
	echo "Please use version > 1.11.x"
}
else{

	#--> Create a RG
	az group create --name ais-aksclass-rg --location $location

	#--> Create a AKS cluster
	az aks create -g ais-aksclass-rg -n aksclass-demo --location $location --kubernetes-version $version --node-count 3 --enable-addons http_application_routing --generate-ssh-keys

	timeout /t 60

	#--> Get the credentials. 
	az aks get-credentials --resource-group ais-aksclass-rg --name aksclass-demo --overwrite

	#--> Make sure the istio pods are running
	kubectl get pods -o wide --all-namespaces

	#--> Wait for 60 secs before launcing the Dashboard
	timeout /t 60

	#--> The following two commands are optional step to open Kubernetes Dashboard
	kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
	az aks browse --resource-group ais-aksclass-rg --name aksclass-demo

	#--> Set Binding as needed ... 
	kubectl create clusterrolebinding itesh-cluster-admin-binding --clusterrole=cluster-admin --user=itesh
	kubectl create clusterrolebinding vlele-cluster-admin-binding --clusterrole=cluster-admin --user=vlele
}