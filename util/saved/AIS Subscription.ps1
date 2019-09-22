# set subscription (WSL)
az login 
az account set --subscription 66cacb0f-a871-4b0b-a161-bd04492f956a


# **************************************
#   AKS RBAC Enabled Cluster
# **************************************
#start
az vm start -g MC_vlaksaad_vlaksaad_eastus -n aks-nodepool1-33016541-0

#stop
az vm stop -g MC_vlaksaad_vlaksaad_eastus -n aks-nodepool1-33016541-0


# get cluster credentials
az aks get-credentials --resource-group vlaksaad --name vlaksaad  

#Browse portal
az aks browse --resource-group MC_vlaksaad_vlaksaad_eastus  --name vlaksaad


