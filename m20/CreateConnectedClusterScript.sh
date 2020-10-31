# This script creates an Azure Arc resource to connect a Kubernetes cluster to Azure
# Documentation: https://aka.ms/azure-arc-for-k8s

# Log into Azure
az login

# Set Azure subscription
az account set --subscription '0d4f44f5-e032-49de-ba6c-86dcf4201a31'

# Create Resource group
az group create --name 'GKE_RG' --location 'eastus'

# Create connected cluster
az connectedk8s connect --name 'cluster-1' --resource-group 'GKE_RG' --location 'eastus'
