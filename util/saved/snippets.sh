az login 
az account list --output table

# set subscription
#-->

# get cluster credentials
#-->

# set the namespace to prod

kubectl config set-context $(kubectl config current-context) --namespace=prod


kubectl cluster-info 

az aks browse --resource-group vlakstest3 --name taskapi-k8s


http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=dev

# bastion pod
k apply -f ../m2/manifests/kuard-pod.yml
kubectl port-forward kuard 8080:8080

# dry
--dry-run ﬂag 

kubectl logs and kubectl logs --previous 
kubectl exec -it <pod> sh 

 kubectl cluster-info