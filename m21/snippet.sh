##***************************************************************************************
## Objective: This module demos the KEDA(Kubernetes-based event-driven autoscaling) based solution in AKS. Event-driven architectures helps to achieve a flexible and decoupled 
## design in enterprise application. Pure k8s based solution lacks on this. Scaling in k8s is reactive, based on the CPU and memory consumption of a container. Services like Azure 
## Functions(AF) are strongly aware of event sources and hence able to scale based on signals coming directly from the event source, even before the CPU or memory are impacted. By ## merging these two worlds i.e.,AF and k8s we can get best of the both worlds. This is called KEDA. AFs can be containerized and deployed to any k8s cluster that lets us scale to 
## and from zero to thousands of containers based on event metrics like the length of a Kafka stream or an Azure Queue.It will also enable containers to consume events directly 
## from the event source instead of decoupling with HTTP. KEDA can drive the scale of any container and is extensible to add new event sources. Apart from this, workloads that may 
## span the cloud and on-premises, we can now choose to publish across cloud-hosted k8s environments, or on-premises. 
#***************************************************************************************
## Steps for the demo :
#   	I.	Re-use an AKS Cluster using Azure CLI in Azure Cloud
#  		II.	Install Azure Functions Core Tools v2 with NPM
# 		III.	Create Azure Function Using v2 Core Tools in PowerShell
#  		IV.	Install and Configure KEDA
#   	V.	Deploy the AF in AKS Cluster
#  		VI.	Test AF in AKS Cluster Postman
## Pre-requisites:
#    - User should have a AKS Cluster already and running in East US/Central US/West US 2/West Europe/Canada Central/Canada East region
#    - Visual Studio Code latest version is installed
# 	 - Use PowerShell for running the Kubectl commands and others unless instructed otherwise
#	 - Install npm from https://nodejs.org/en/download/(node-v10.16.3-x64.msi) and add ";C:\Program Files\nodejs\" to the Path environment variable
## Cleanup: Make sure cleanup steps has been run

#--> Set Alias(optional)  
Set-Alias k kubectl

#--> Go to m21 module directory
cd ..\m21

$rg_name = "aks-class-new"
$cluster_name = "aks-class"
$storageaccname = "jsqueueitemskeda"
$location="eastus"
$namespace = "keda"
$acrreponame = "vlakstest1b359"
$acrreporegistry = "vlakstest1b359.azurecr.io"

# Create and set context to "$namespace" namespace
kubectl create namespace $namespace
kubectl config set-context $(kubectl config current-context) --namespace=$namespace
# Use the context
kubectl config use-context $(kubectl config current-context)

#--> Register providers needed for AKS cluster
az provider register -n Microsoft.ContainerInstance
az provider register -n Microsoft.ContainerService

## I.	RE-USE CLUSTER(AKSCLASS-DEMO) IN RG $rg_name
#--> Create a storage account and a queue named "js-queue-items" in the RG $rg_name 
az storage account create --sku Standard_LRS -l  $location -g $rg_name -n $storageaccname

$CONNECTION_STRING=(az storage account show-connection-string --name $storageaccname --query connectionString)
az storage queue create -n “js-queue-items” --connection-string $CONNECTION_STRING

#--> Show Connection String and save it to a notepad
az storage account show-connection-string --name $storageaccname  --query connectionString

#--> Configure the AllowedHeaders & ExposedHeaders in CORS configuration to * i.e. allow all headers & return all headers
> Go to Azure Portal "Home -> Resource groups -> $rg_name -> $storageaccname - CORS". Enter the below inputs and click "Save"
#--> 	"ALLOWED ORIGINS = *" 
#--> 	"ALLOWED METHODS  = "GET, POST, PUT and PATCH
#--> 	"ALLOWED HEADERS = *" 
#--> 	"EXPOSED HEADERS = *"  
#--> 	"MAX AGE = *"  

#--> Create Shared Access Signature in the azure portal as below and then copy the value of the “SAS token” into a notepad
> Go to Azure Portal and navigate to "Home -> Resource groups -> $rg_name -> $storageaccname - Shared access signature"
> Click "Generate SAS and connection string" and then copy it into a notepad

## II.	INSTALL AZURE FUNCTIONS CORE TOOLS V2 WITH NPM
#--> Note: This includes a version of the same runtime that powers Azure Functions runtime in azure which can be run on our local development computer. It also provides commands to create functions, connect to Azure, and deploy function projects. Version 2.x of the tools uses the Azure Functions runtime 2.x that is built on .NET Core. 
#--> Install Azure Functions Core Tools v2 with npm 
npm i -g azure-functions-core-tools --unsafe-perm true

#--> Set Environment Path for "func" as "C:\Users\<Logged in Users directory in the Laptop/PC/VM>\AppData\Roaming\npm"
> Type “Env” and click the "Edit System Environment Variable" into “Type here to search” Textbox. You can find next to “Windows Start” 
> Click the "Environment Variable" -> edit the “Path” Variable in "User Variables" and "System Variables" 
> Add a new entry for the above folder path and click "OK" 


## III.	CREATE AN AZURE FUNCTION IN LOCAL PC USING CORE TOOLS V2 & POWERSHELL
#--> The next step is to use the “func” commands to create an AF and configure for running locally, debugging and deploying
#--> Initialize the directory for functions in Powershell,

# Login to acr
az acr login --name $acrreponame

> In the right bottom corner of your machine right click on "Docker" Icon and "Switch to Linux containers"
func init . –docker
> Select a worker runtime: node
> Select a Language: javascript
#-->  Sample Output:
#-->      Writing package.json
#-->      Writing .gitignore
#-->      Writing host.json
#-->      Writing local.settings.json
#-->      Writing ..\.vscode\extensions.json
#-->      Writing Dockerfile
#-->      Writing .dockerignore

#--> Add a new queue triggered function,
func new
> Select "Azure Queue Storage Trigger" as input and press "Enter" --> then press "Enter" again to take the "QueueTrigger" as default   
#-->  Sample Output:
#-->      ....
#-->      The function "QueueTrigger" was created successfully from the "Azure Queue Storage trigger" template.

> Update "..\local.settings.json" file with the connection string from notepad or Portal(Home --> Resource groups--> $rg_name --> js-queue-items - Access keys) as below:    
#-->     	{
#-->     	    "IsEncrypted": false,
#-->     	    "Values": {
#-->     			"FUNCTIONS_WORKER_RUNTIME": "node",
#-->     			"AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=jsqueueitemsforkedademo;AccountKey=Q2YUUGGkIGHo9jWTvnzVT3V1Q9PlSa3Ce+cfGM31J7OGbLoCelVvBJ45bmtmKyhlFa4+1QW5sLIiHIUQkt1iPA==;EndpointSuffix=core.windows.net" 
#-->     		          }
#-->     	}

> Update the "..\QueueTrigger\function.json" file as below:
#-->     	{
#-->     	"bindings": [
#-->     					{
#-->     						"name": "myQueueItem",
#-->     						"type": "queueTrigger",
#-->     						"direction": "in",
#-->     						"queueName": "js-queue-items",
#-->     						"connection": "AzureWebJobsStorage"
#-->     					}
#-->     		]
#-->     	}

> Update the "..\host.json" file as below:
#-->     	{
#-->     		"version":  "2.0",
#-->     		"extensionBundle": {
#-->     				"id": "Microsoft.Azure.Functions.ExtensionBundle",
#-->     				"version": "[1.*, 2.0.0]"
#-->     			}
#-->     	}

# Start the function locally
func start

#--> Note: No Error should be shown. Errors are shown in yellow or red

# Add a message to the Queue as mentioned below and the PS window should show it. Follow the steps below,
> In Azure Portal go to "Home -> Resource groups -> $rg_name -> $storageaccname - Queues -> js-queue-items". Click "+ Add message"
#-->  Add a message(Hello KEDA! This is a test.) into the "Message text" Textbox and click "OK" to trigger an Event.
#-->  Notice that the message is displayed to the Powershell window
#-->  Press "Ctrl + C"  in the Powershell window to shut down 


# IV.	INSTALL AND CONFIGURE KEDA 
# Install “KEDA” using “func” commands. Execute the below commands in a PowerShell window,
func kubernetes install --namespace $namespace

#--> Confirm that KEDA has been successfully installed. The output should show "scaledobjects.keda.k8s.io" object
kubectl get customresourcedefinition  

# V.	DEPLOY THE AZURE FUNCTION(AF) IN AKS CLUSTER 
# Deploy a “JavaScript queue trigger” AF to KEDA  and then proceed with the steps for testing the same in AKS. The AF is auto-generated by the Tool and will run in a Pod when a message is sent to the Storage Queue. As the number of messages keep growing the number of Pods will also grow. Once all messages are removed from the Queue these Pods are automatically removed from AKS. The number of Pods are scaled up/down as needed automatically and is shown in the demo.

#--> Deploy Function App to KEDA(standard)using he command below. It will be partially successful as it won't find the docker image necessary format. We will need to tag correctly and run it again.

func kubernetes deploy --name hello-keda --registry $acrreporegistry
#-->  Sample Output:
#-->    Running 'docker build -t vlakstest1b359.azurecr.io/hello-keda D:\aks-class-new\m21\hello-keda'..done
#-->    Running 'docker push vlakstest1b359.azurecr.io/hello-keda'...................................done
#-->    secret/hello-keda created
#-->    deployment.apps/hello-keda created
#-->    scaledobject.keda.k8s.io/hello-keda created

#--> Deploy the Azure Function to AKS. First, we will give a dry run and create a “deploy.yaml”. Then we will create a “ImagePullSecret” and edit the  file and redeploy,
func kubernetes deploy --name hello-keda --registry $acrreporegistry  --dry-run > deploy.yaml
#-->Check the "deploy.yaml" file and notice that there is no "ImagePullSecret". 

#--> Before we create a  “ImagePullSecret”, we change the kubectl context to default namespace,
kubectl config current-context
kubectl config set-context $(kubectl config current-context) --namespace=default

#--> Create a  “ImagePullSecret” by giving your e-mail id and ,
kubectl create secret docker-registry hello-keda-secret --docker-server $acrreporegistry --docker-email vishwas.lele@appliedis.com --docker-username=vlakstest1b359 --docker-password  a0ahbi2+Ug7xIWSOEQaCbtKGdok0lROm --namespace $namespace
#-->  Sample Output:
#-->  	secret/hello-keda-secret created

#--> Get the Service Account by executing below command and check that the "serviceaccount.yml" file is really created after execution 
kubectl get serviceaccounts default -o yaml > ./serviceaccount.yml

> Edit the  "serviceaccount.yml" file and update the secrets name as
#--> secrets:
#-->	- name: hello-keda-secret

#--> Execute the below command to update serviceaccount, 
kubectl replace serviceaccount default -f ./serviceaccount.yml
#-->  Sample Output:
#-->    serviceaccount "default" replaced

> Update the "deploy.yaml" file with below lines and then deploy the Azure Function to AKS
#--> imagePullSecrets:
#--> 	- name: hello-keda-secret

kubectl apply -f deploy.yaml
#-->  Sample Output:
#-->  	secret "hello-keda" unchanged
#-->  	deployment.apps "hello-keda" configured
#-->  	scaledobject.keda.k8s.io "hello-keda" configured

#--> Open the Dashboard and check the deployment
az aks browse --resource-group $rg_name --name $cluster_name   

# VI.	TEST AZURE FUNCTION(JAVASCRIPT) USING POSTMAN 
#--> Now let’s do some tests using Postman and check that the KEDA is working  correctly in AKS. Before starting the tests first check the pods in AKS with an empty queue you should see 0 pods. Then run the Postman command using "Runner" for 15 iterations. As the number of messages keep growing the number of pods starts popping up. You can see this using watch flag in kubectl

#--> Run the below command in PowerShell and ensure that you see '0' KEDA created pods in default namespace. 
kubectl get pods

#--> Use Postman, add 15 messages into the storage queue and validate the AKS scales with KEDA. 
> Import “KEDADemoScaleUp.postman_collection.json” and “KEDA-Demo.postman_environment.json” into Postman from "..\manifests\Postman Collections" folder.
> Choose the collection “KEDADemoScaleUp” and environment “KEDA-Demo”
> Copy the SAS Token saved previously in a notepad or from azure portal and update the “KEDA-Demo” environment variable “storageSasTokenQueryString”

#--> Clear the queue(if any) in azure portal as shown below:
> In Azure Portal go to "Home -> Resource groups -> $rg_name -> $storageaccname - Queues -> js-queue-items-poison" and click "Clear queue"

> In the Postman, click the “Runner” Button on the top-left corner -> select the “KEDADemoScaleUp” collection -> Choose the "Environment" “KEDA-Demo” -> Edit "Iteration" to 15 and Click "Run KEDADemo.." 

#--> Verify in the PowerShell window the Pods are being created by running the below command and destroyed afterwards
kubectl get pods -w

#--> Verify the messages are really sent to the azure queue as shown below:
> Go to Azure Portal and navigate to "Home -> Resource groups -> $rg_name -> $storageaccname - Queues -> js-queue-items-poison"

# Cleanup Steps:
kubectl delete -f deploy.yaml
kubectl delete deploy hello-keda
kubectl delete ScaledObject hello-keda
kubectl delete Secret hello-keda
> delete storage account $storageaccname
kubectl delete namespace $namespace