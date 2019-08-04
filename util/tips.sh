https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh

Cnt E
CNTRL A
CNTRL K

Kubectl logs
kubectl logs m1pod
OLD_IMAGES=$(docker images |awk '{if (($4 > 10 && $5 == "minutes")) {print $3}}')
docker rmi ${OLD_IMAGES[@]}


kubectl exec -it shell-demo -- /bin/bash

# set alias
alias k='kubectl'