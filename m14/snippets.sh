
#Firstly, let's add the add-on Ingress controller and DNS service:

az aks enable-addons --resource-group $RG --name $NAME --addons http_application_routing

#Then we can check to see what the root of our applications DNS will be:

az aks show --resource-group $RG --name $NAME --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table

#When we create an ingress and assoicate it with our application service, we will add the ingress name to this dns domain to get our DNS 'pointer' back to our application.  e.g. if we create an ingress called hostname, then our new pointer will be:

hostname.{DNS_root}

#In the yaml file change the hostname
#  - host: hostname.<CLUSTER_SPECIFIC_DNS_ZONE>

#Then apply the ingress to our environment:
kubectl apply -f .\manifests\hostname_ingress.yml

#and then we can test for dns update (which may take a few minutes):

while [ 1 ] ; do
curl http://hostname.<DNS_NAME>
sleep 30
done




