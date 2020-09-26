# Build a RBAC-powered service principal
RBAC=$(az.cmd ad sp create-for-rbac -o json)

# Get the Subscription ID for the Azure Account
export AZURE_SUBSCRIPTION_ID=$(az.cmd account show --query id --out tsv)

# Get the Tenant ID, Client ID, Client Secret and Service Principal Name from Azure.
export AZURE_TENANT_ID=$(echo ${RBAC} | jq -r .tenant)
export AZURE_CLIENT_ID=$(echo ${RBAC} | jq -r .appId)
export AZURE_CLIENT_SECRET=$(echo ${RBAC} | jq -r .password)
export AZURE_SP_NAME=$(echo ${RBAC} | jq -r .name)

echo "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID=$AZURE_TENANT_ID"
echo "AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET"
echo "AZURE_SP_NAME=$AZURE_SP_NAME"