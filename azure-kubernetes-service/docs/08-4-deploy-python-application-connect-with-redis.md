
---
Owner: Yuwei
Prerequisites:
- AKS
- Redis
Output:
- Template to deploy the application to cluster
- How to pull the image from ACR to cluster
- Config service endpoint to find each other
---

## Cart Service

### Create Redis Cache and save to Kubernetes

Will use Workload Identity for application to access Redis passwordlessly. For more details, see https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster

### Create managed identity

1. Create identity

```
az identity create -n acme-cart-identity -g yuwzho-acme --location eastus2 --subscription a4ab3025-1b32-4394-92e0-d07c1ebf3787
```

### Assign Redis access to the identity

```
OBJECT_ID=$(az identity show -n acme-cart-identity -g yuwzho-acme --query principalId -o tsv)
az redis access-policy-assignment create \
    --access-policy-name "Data Owner"  \
    -n yuwzho-acme-redis \
    -g yuwzho-acme \
    --object-id ${OBJECT_ID} \
    --object-id-alias acme-cart-identity \
    --policy-assignment-name ${OBJECT_ID}
```

### Add federated credential for managed identity

```
AKS_OIDC_ISSUER=$(az aks show --name yuwzho-acme-k8s \
    --resource-group yuwzho-acme \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv)

az identity federated-credential create \
    --name cart_acme_redis \
    --identity-name acme-cart-identity \
    --resource-group yuwzho-acme \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject system:serviceaccount:default:sa-account-redis-cart \
    --audience api://AzureADTokenExchange
```


### Update yaml for the credetial and Redis host
```
CLIENT_ID=$(az identity show -n acme-cart-identity -g yuwzho-acme --query id -o tsv)
echo client-id: ${CLIENT_ID}
echo redis-access-policy-assignment-name: ${OBJECT_ID}
REDIS_HOSTNAME=$(az redis show -n yuwzho-acme-redis -g yuwzho-acme --query hostName -o tsv)
echo redis-hostname: ${REDIS_HOSTNAME}
```

Open `azure-kubernetes-service/resources/applications/acme-cart.yml` and update the following placeholders according to previous step's output.
- `<client-id>`
- `<redis-access-policy-assignment-name>`
- `<redis-hostname>`

## Deploy the acme-cart service

1. Apply the resource
```
kubectl apply -f resources/applications/acme-cart.yml
```
