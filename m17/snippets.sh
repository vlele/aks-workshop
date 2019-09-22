kubectl apply -f manifests/hostname.yml

#You can see the progress of this process with:
kubectl get svc hostname -w

When the public IP changes from <pending> to a value, navigate to the IP with your web browser to verify the app is working.

 http://<ip_from_service_external>/swagger

#Applications can be scaled in multiple ways, from manual to automatic at the POD level:

#You can manually define the number of pods with:
kubectl scale --replicas=5 deployment/hostname-v1
kubectl get pods

#Update the hostname deployment CPU requests and limits to the following:

#kubectl apply -f hostname.yml

#Now scale your app with the following:
kubectl autoscale deployment hostname-v1 --cpu-percent=50 --min=3 --max=10

#You can see the status of your pods with:
kubectl get hpa
kubectl get pods

#The manually set number of replicas (5) should reduce to 3 given there is minimal load on the app.

#It is also possible to change the actual k8s cluster size. During cluster creation, you can set the cluster size with the flag: --node-count

#If we didn't enable cluster-autoscale, we could manually change the pool size after creation you can change the node pool size using:
az aks scale --resource-group $RG --name $NAME --node-count 3

#The auto-scaling needs to be done at cluster create time, as it is not possible to enable autoscaling at the moment, or to change the min and max node counts on the fly (though we can manually change the node count in our cluster).

#In order to trigger an autoscale, we can first remove the POD autoscaling hpa service:

kubectl delete hpa hostname-v1

#Then we can scale our PODs (we set a max of 20 per node) to 25:

kubectl delete hpa hostname-v1
kubectl scale --replicas=25 deployment/hostname-v1

#After a few minutes, we should see 25 pods running across at least two if not all three nodes in our autoscale group
 
kubectl get pods -o wide -w


#A last method for manipulating the node/POD relationship includes taints and tolerations, which allows us to manually define specific nodes to allow or disallow POD deployments.  There is also a less draconian approach using selectors and affinity.  We will enable an affinity approach based on node labels.

#First we need to manually scale our cluster to have two resources:
az aks update --disable-cluster-autoscaler --resource-group $RG --name $NAME
az aks scale --resource-group $RG --name $NAME --node-count 2

kubectl get nodes 

kubectl label node <new_node_name> anykey=anyvalue

#We can then edit a container specification in a POD or Deployment to include a nodeSelector that matches the node label, forcing that POD to be deployed only to that node (assuming there is capacity).

spec:
  nodeSelector:
    anykey: anyvalue

And this will force the scheduling of this pod to our second node and will deploy 5 replicas (which should only be applied to the second node)

kubectl apply -f hostname-anykey.yml

We can also deploy and scale our original hostname app that doesn't have the same restrictions, of which some PODs should be scheduled to our original node:

kubectl apply -f hostname.yml
kubectl scale deploy hostname-v1 --replicas=5

Get pods with node assignments

kubectl get pods -o wide | awk '{print $1 " " $7}'
or (if you don't have awk in your CLI)
kubectl get pods -o wide





