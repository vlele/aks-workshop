# Cleans all kubernetes objects
# check the context first
kubectl delete daemonset,services,configmap,pods --all
kubectl delete statefulset --all
kubectl delete rs --all
kubectl delete daemonset --all
kubectl delete job --all
kubectl delete service --all
kubectl delete pods --all


