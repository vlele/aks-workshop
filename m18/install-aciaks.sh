MASTER_URI=https://aks-worksh-aks-workshop-rg-a84ff4-d776a85e.hcp.eastus.azmk8s.io:443
RELEASE_NAME=virtual-kubelet
VK_RELEASE=virtual-kubelet-latest
NODE_NAME=virtual-kubelet
CHART_URL=https://github.com/virtual-kubelet/virtual-kubelet/raw/master/charts/$VK_RELEASE.tgz
NAMESPACE=aciaks

echo "MASTER_URI=$MASTER_URI"
echo "RELEASE_NAME=$RELEASE_NAME"
echo "VK_RELEASE=$VK_RELEASE"
echo "NODE_NAME=$NODE_NAME"
echo "CHART_URL=$CHART_URL"


rm -r $RELEASE_NAME
rm -r $VK_RELEASE.tgz
helm fetch --untar $CHART_URL

sed -i 's|extensions/v1beta1|apps/v1|g' ./$RELEASE_NAME/templates/deployment.yaml
sed -i 's|  template:|  selector:\n    matchLabels:\n      app: {{ template "vk.name" . }}\n  template: |g' ./$RELEASE_NAME/templates/deployment.yaml
helm install $NODE_NAME -g --namespace $NAMESPACE --set provider=azure --set providers.azure.targetAKS=true --set providers.azure.masterUri=$MASTER_URI 