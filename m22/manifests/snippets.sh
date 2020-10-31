# Create and configure a state store, install Redis 
  helm install redis bitnami/redis
  kubectl get pods -w
  kubectl describe secret redis 
  
# Edit the below yaml in "..\dapr-aks\quickstarts\hello-kubernetes\deploy" files for redisHost & redisPassword,
	  metadata:
	  - name: redisHost
		value: redis-master.default.svc.cluster.local:6379
	  - name: redisPassword
		secretKeyRef:
			name: redis
			key: redis-password
  kubectl apply -f ./deploy/redis.yaml 
  
# Deploy the Node.js app with the Dapr sidecar in namespace $namespace
 kubectl apply -f ./deploy/node.yaml 

# Verify Service call using external IP
kubectl get svc nodeapp -w  

  After 2-3 mins execute below command,
  > curl "http://<EXTERNAL-IP>/ports" 

# Deploy the Python app to your Kubernetes cluster with the Dapr sidecar:
  > kubectl apply -f ./deploy/python.yaml  
  > kubectl get pods --selector=app=python -w  
   kubectl logs --selector=app=node -c node  
    
Cleanup:
kubectl delete -f ./deploy/python.yaml
kubectl delete -f ./deploy/node.yaml
kubectl delete -f ./deploy/redis.yaml
helm uninstall redis 
