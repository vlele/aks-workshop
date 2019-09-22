# Get the resource group name
az aks show --resource-group vlakstest3 --name taskapi-k8s --query nodeResourceGroup -o tsv

# List the VMs in the AKS cluster resource group 
az vm list --resource-group MC_vlakstest3_taskapi-k8s_eastus -o table

# generate a public key putthgen
az vm user update --resource-group MC_vlakstest3_taskapi-k8s_eastus --name aks-nodepool1-23123819-1  --username azureuser --ssh-key-value C:\Users\vishw\OneDrive\aks\id_rsa

az vm list-ip-addresses --resource-group MC_vlakstest3_taskapi-k8s_eastus -o table

kubectl run -it --rm aks-ssh --image=debian
apt-get update && apt-get install openssh-client -y
kubectl cp ~/.ssh/id_rsa aks-ssh-554b746bcf-kbwvf:/id_rsa
chmod 0600 id_rsa
ssh -i id_rsa azureuser@10.240.0.4