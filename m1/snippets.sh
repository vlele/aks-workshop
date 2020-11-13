##***************************************************************************************
##  Objective: This module builds the Task API sample and deploys it to the AKS cluster
##***************************************************************************************
##   Prerequisites:
##   #--> Go to m1 module directory
cd ..\m1
##***************************************************************************************
 
NAMESPACE="prod"
kubectl create namespace $NAMESPACE

# Set context to "prod"

#Delete the m1 directory 
# Create a scratch directory under m1 
mkdir scratch
cd scratch 

# Clone
git clone https://github.com/vlele/aks
-workshop

cd aks/aisazdevops-taskapi 


# Clean up images if some are still left e.g.,
docker image prune -a

# Build the docker image
# Make sure linux containers are selected 
docker build -t taskapi-aspnetcore-v1.0.0 .

# Browse to Azure container registry  and delete any image with the "taskapi-aspnetcore:v1" name 
# repository taskapi-aspnetcore 
# delete v1 

# Tag the image 
docker tag taskapi-aspnetcore-v1.0.0 <name>.azurecr.io/taskapi-aspnetcore:v1

# Logon to acr
#az acr create -n <name> -g <RG> --sku Basic
az acr login --name <name>

# Show repositories and tags
az acr repository show-tags --name <name> --repository taskapi-aspnetcore¥¥ --output table


# Push the acr (created using the DevOps project)
docker push <name>.azurecr.io/taskapi-aspnetcore:v1

# docker pull <name>.azurecr.io/taskapi-aspnetcore:v1
# docker images 
# docker inspect < image_id>
# The hex element is calculated by applying the algorithm (SHA256) to a layer's content.
#  docker run -d -p30090:80 <image id>

# Create a Kube secret
kubectl create secret docker-registry taskapiacrsecret  --docker-server <name>.azurecr.io --docker-email john.doe@example.com --docker-username=<name> --docker-password  "PWD" --namespace prod
kubectl delete secret k taskapiacrsecret --docker-server <name>.azurecr.io --docker-email john.doe@example.com --docker-username=<name> --namespace prod

# Go to m1 folder ..\m1 and edit pod.yaml at image: <Log-in-server>/taskapi-aspnetcore:v1
cd ../../..

kubectl create -f pod.yml
# see the http calls
kubectl get pods --v=7

# Port forard local 8080 to port 80 on the pod (via the master)
kubectl port-forward m1pod 8080:80

# Bring up the swagger file 
http://localhost:8080/swagger


# Cleanup 
# Clean all kube objects 
kubectl delete secret taskapiacrsecret;
kubectl delete namespace prod
kubectl delete configmap taskapi-aspnetcore-config-v1;
# kubectl delete pod m1pod
