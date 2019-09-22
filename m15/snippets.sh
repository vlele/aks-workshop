#In AKS, two initial StorageClasses are created:

#default - Uses Azure Standard storage to create a Managed Disk. The reclaim policy indicates that the underlying Azure Disk is deleted when the pod that used it is deleted.
#managed-premium - Uses Azure Premium storage to create Managed Disk. The reclaim policy again indicates that the underlying Azure Disk is deleted when the pod that used it is deleted.

k get sc

#Additional storage classes can be create with kubectl.

#Lets create a managed premium storage class details that will retain the persistent volume after pod deletion:
#Retain -- versus Delete

k create -f manifests/storage.yaml

#A PersistentVolumeClaim requests either Disk or File storage of a particular StorageClass, access mode, and size. The Kubernetes API server can dynamically provision the underlying storage resource in Azure if there is no existing resource to fulfill the claim based on the defined StorageClass. The pod definition includes the volume mount once the volume has been connected to the pod.
# The hostname_volume.yaml file is made up of three components, a deployment of our simple hostname application, a service with LoadBalancer type so that we can reach the application from the public network, and a PVC with our retained policy volume. 

kubectl apply -f manifests/hostname_volume.yaml


#Shared volumes must be of the Azure File type. Azure files only work with Standard storage. They will fail if you try using Premium.

#In most cases persistent _disk_ storage is only available in a one-to-one mapping connecting a disk to a pod directly. In AKS, it is also possible to map _file_ style resources, which use the SMB storage model, and allow multiple connections and multiple read and write resources.  In order to use the file storage resources, we first need to create a storage account if we don't have one already, and it needs to be associated with our AKS enviornment.  Find our node resource class name:

az aks show --resource-group $RG --name $NAME --query nodeResourceGroup -o tsv
MC="MC_vlakstest5_RG_vlakstest5_eastus2"
STORAGE_NAME="vlakstest5storage"
#Then we can create a storage account with that resource group (note that the group should start with MC_):
az storage account create -n $STORAGE_NAME -g $MC -l $LOCATION --sku Standard_LRS

#Now we can create the storage class, and a role and role binding which are needed to allow the storage controller to create a secret for the PVC to use for accessing the file share resource.
#Create the storage class:

kubectl apply -f manifests/file_sc.yml

#And the Cluster Role and Role Binding (RBAC parameters):
kubectl apply -f manifests/file_pvc_roles.yml

#Finally, we can create a shared PVC:
kubectl apply -f manifests/file_pvc.yml

#Lastly, we can see that the file was created:
kubectl get pvc azurefile

#And if we attach the PVC to a pod as we did previously, we can attach more than one POD to the same file resource:

kubectl apply -f manifests/hostname_file.yml

#And we can now write into, and read from the two pods to see that the both mount the same filesystem:

kubectl exec -it $(kubectl get pod -l app=hostname-file -o jsonpath='{.items[0].metadata.name}') -- sh -c 'hostname > /www/hostname; cat /www/hostname'
kubectl exec -it $(kubectl get pod -l app=hostname-file -o jsonpath='{.items[1].metadata.name}') -- sh -c 'cat /www/hostname'

#Persistent Volumes and Persistent Volume Claims are resources that can be discovered in our Kubernetes enviornment:

kubectl get pvc
kubectl get pv

#We should also clean up any PODs that have PVCs (and therefore PVs) associated with them:

kubectl get deployments
kubectl get pods

#We can then delete unwanted resources:

kubectl delete deployment <deploymentName>

kubectl delete pvc <pvcName>

kubectl delete pv <pvName>

#And for good measure we should see if we have any services that are no longer needed as well:

kubectl get service
kubectl delete svc <serviceName>

