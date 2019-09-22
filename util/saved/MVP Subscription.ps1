#*****************************************************
# cluster #1   - line #8   DevOps project
# cluster #3   - line #31  Concepts 
# cluster #4   - line #44  ACI, Svc Catalog (module #6)
# cluster #5   - line #59  DevSpaces
# cluster #6   - line #75  Istio  (modules  12)
#******************************************************

# login 
az login --use-device-code


# set subscription
az account set --subscription 	0d4f44f5-e032-49de-ba6c-86dcf4201a31
az account set --subscription "Microsoft Azure Sponsorship"

# **************************************
#   AKS connected to DevOps Project -- 1
# **************************************
#start
az vm start -g MC_vlakstest1b3bd_vlakstest1_eastus -n aks-agentpool-33214111-1

#stop
az vm stop -g MC_vlakstest1b3bd_vlakstest1_eastus -n aks-agentpool-33214111-1

# get cluster credentials
az aks get-credentials --resource-group vlakstest1b3bd --name vlakstest1 --overwrite


# *********************************
#   AKS Cluster Concepts  ----    3
# *********************************

#start
az vm start -g MC_vlakstest3_taskapi-k8s_eastus -n  aks-nodepool1-23123819-1

#stop
az vm stop -g MC_vlakstest3_taskapi-k8s_eastus -n  aks-nodepool1-23123819-1

# get cluster credentials
az aks get-credentials --resource-group vlakstest3 --name taskapi-k8s --overwrite

# **********************************************
#   Azure AKS Cluster - AKS ACI, Catalog  ---- 4
# **********************************************

#start
az vm start -g MC_vlakstest4_RG_vlakstest4cluster_eastus -n aks-nodepool1-35999150-0

#stop
az vm stop -g MC_vlakstest4_RG_vlakstest4cluster_eastus -n aks-nodepool1-35999150-0

# get cluster credentials
az aks get-credentials --resource-group vlakstest4_RG --name vlakstest4cluster --overwrite



# **********************************************
#   Azure AKS Cluster - Dev Spaces --          5
# **********************************************

#start
az vm start -g MC_ais-azdevspace-rg_vlakstest5_eastus -n aks-nodepool1-22983318-0
az vm start -g MC_ais-azdevspace-rg_vlakstest5_eastus -n aks-nodepool1-22983318-1

#stop
az vm stop -g MC_ais-azdevspace-rg_vlakstest5_eastus -n aks-nodepool1-22983318-0
az vm stop -g MC_ais-azdevspace-rg_vlakstest5_eastus -n aks-nodepool1-22983318-1

# get cluster credentials
az aks get-credentials --resource-group ais-azdevspace-rg --name vlakstest5 --overwrite


# *************************************
#   Azure AKS Cluster - Istio       
# *************************************

#start
az vm start -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-0
az vm start -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-2
az vm start -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-1


#stop
az vm stop -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-0
az vm stop -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-1
az vm stop -g MC_ais-istio-rg_taskapi-istio1_eastus -n aks-nodepool1-41527786-2


# get cluster credentials
az aks get-credentials --resource-group ais-istio2-rg  --name taskapi-istio1 --admin --overwrite
