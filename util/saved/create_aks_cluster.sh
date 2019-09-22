# set alias
alias k='kubectl'

# login 
az login --use-device-code
kubectl port-forward m1pod 8080:80

# set subscription
az account set --subscription 	0d4f44f5-e032-49de-ba6c-86dcf4201a31
az account set --subscription "Microsoft Azure Sponsorship"


# Utils\ClusterDetails

# Create Resource Group
az group create --name $RG --location $LOCATION

# Create AKS CLuster
az aks create --resource-group $RG --name $NAME --node-count 1 --enable-addons monitoring --generate-ssh-keys   

#  Delete Cluster
az aks delete --name $NAME --resource-group $RG
#note
SSH key files '/Users/Vishwas/.ssh/id_rsa' and '/Users/Vishwas/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage like Azure Cloud Shell without an attached file share, back up your keys to a safe location

# get cluster credentials
az aks get-credentials --resource-group $RG --name $NAME  --overwrite

kubectl config set-context $(kubectl config current-context) --namespace=prod


#delete
az aks delete --name $NAME --resource-group $RG --no-wait  --yes
