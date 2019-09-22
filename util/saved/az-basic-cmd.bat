echo off
IF "%1" == "help" (
echo "This batch file is used for setting up PowerShell environment.Execute above batch file as below"
echo "Example: .\az-basic-cmd.bat <subscription id>, <location>"
echo "Please use location as 'East US'/'Central US'/'West US 2'/'West Europe'/'Canada Central'/'Canada East region'"
)
IF NOT "%1" == "help" (
echo on
echo "Executing Azure Common Commands to run in a fresh PowerShell Window"
call az login
call az account set --subscription %1  
call az account list -o table
call az provider register -n Microsoft.ContainerService
call az provider register -n Microsoft.Network
call az provider register -n Microsoft.Storage
call az provider register -n Microsoft.Compute
call az provider register -n Microsoft.ContainerInstance
call az configure --defaults location=%2
title "Checking the locations that support Microsoft.ContainerService"
:: call az provider list --query "[?namespace=='Microsoft.ContainerService'].resourceTypes[] | [?resourceType=='managedClusters'].locations[]" -o tsv
:: call az provider list --query "[?namespace=='Microsoft.ContainerInstance'].resourceTypes[] | [?resourceType=='managedClusters'].locations[]" -o tsv
title "Checking the Kubernetes Versions supported at %2 location"
call az aks get-versions --location %2 --query "orchestrators[].orchestratorVersion"
)
