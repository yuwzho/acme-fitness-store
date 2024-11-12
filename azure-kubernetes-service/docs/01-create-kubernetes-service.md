---
Onwer: Yuwei
Output:
  - Create ACR
  - Create AKS that connects to the ACR
  - Create Key Vault
  - Create Ingress with CA cert
---

## Create Resource Group
1. Create RG
`az group create -n yuwzho-acme -l eastus2`

##  Create Azure Container Registry
1. Create ACR
`az acr create -g yuwzho-acme -n acmeacr --sku Premium`


##  Create AKS
1. Enable `EncryptionAtHost`,  may take 10+ minutes to finish
`az feature register --namespace Microsoft.Compute --name EncryptionAtHost`
Run `az feature register --namespace Microsoft.Compute --name EncryptionAtHost` to wait it state to `Registered`.

1. Create workspace
```
az monitor log-analytics workspace create --resource-group yuwzho-acme --workspace-name yuwzho-acme-workspace
```

1. Create AKS

```
WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group yuwzho-acme --workspace-name yuwzho-acme-workspace --query id -o tsv)
```

```
az aks create \
    -g  yuwzho-acme \
    -n yuwzho-acme-k8s \
    --attach-acr acmeacr \
    --enable-workload-identity  \
    --load-balancer-sku standard \
    --enable-cluster-autoscaler \
    --max-count 40 \
    --min-count 1  \
    --network-plugin azure \
    --no-ssh-key \
    --enable-encryption-at-host \
    --outbound-type loadBalancer  \
    --enable-oidc-issuer \
    --enable-aad \
    --vm-set-type VirtualMachineScaleSets \
    --os-sku Mariner  \
    --node-osdisk-size 100 \
    --node-osdisk-type Ephemeral \
    --node-vm-size Standard_D4as_v4 \
    --enable-azure-monitor-metrics \
    --enable-addons monitoring \
    --workspace-resource-id ${WORKSPACE_ID}
```

```
az aks nodepool add \
    --cluster-name yuwzho-acme-k8s \
    -g yuwzho-acme \
    -n nodepool2 \
    --enable-cluster-autoscaler \
    --enable-encryption-at-host \
    --max-count 40 \
    --min-count 1 \
    --node-osdisk-size 200 \
    --node-osdisk-type Ephemeral \
    --node-vm-size Standard_D8as_v4 \
    --os-sku Mariner \
    --os-type Linux \
    --node-count 1

az aks nodepool add \
    --cluster-name yuwzho-acme-k8s \
    -g yuwzho-acme \
    -n nodepool3 \
    --enable-cluster-autoscaler \
    --enable-encryption-at-host \
    --max-count 40 \
    --min-count 1 \
    --node-osdisk-size 200 \
    --node-osdisk-type Ephemeral \
    --node-vm-size Standard_D16as_v4 \
    --os-sku Mariner \
    --os-type Linux \
    --node-count 1
```


1. Retrieve access token

```
az aks get-credentials --resource-group yuwzho-acme --name yuwzho-acme-k8s --overwrite-existing --admin
```

> For more access management, see https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac?tabs=portal

1. Install or update the kubectl CLI
```
az aks install-cli
```

1. Verify you can connect to the AKS

```
kubectl get ns
```


## Create Azure Keyvault and cert

1. Get AKS outbount IPs and note these IPs as `<AKS-outbound-ip>`
```
az aks show -g  yuwzho-acme -n yuwzho-acme-k8s --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
az resource show --ids <the ID from previous output> --query properties.ipAddress -o tsv
```

1. Get AKS Vnet IDs
```
NODE_RESOURCE_GROUP=$(az aks show --resource-group yuwzho-acme --name yuwzho-acme-k8s --query nodeResourceGroup -o tsv)
az resource list --resource-type microsoft.network/virtualnetworks -g MC_yuwzho-acme_yuwzho-acme-k8s_eastus2 --query "[?starts_with(name, 'aks-vnet')].name" -o tsv
```

List all subnet under the vnet, note these ids are `<subnet-ids>`
```
az network vnet subnet list --resource-group ${NODE_RESOURCE_GROUP} --vnet-name <vnetName> --query "[].id" -o tsv
```

1. Create Azure KeyVault
`az keyvault create --resource-group yuwzho-acme --name yuwzho-acme-kv --network-acls-ips <AKS-outbound-ip> --network-acls-vnets <subnet-ids>`

1. Assign access to yourself
```
# Get your Azure AD user ID
USER_ID=$(az ad signed-in-user show --query id --output tsv)
KEYVUALT_ID=$(az keyvault show --name yuwzho-acme-kv --query id --output tsv)
# Assign yourself the necessary permissions
az role assignment create --role "Key Vault Certificates Officer" --assignee $USER_ID --scope $KEYVUALT_ID
```

1. Create a self-signed certficate or import your CA cert to the Keyvault, ref: https://learn.microsoft.com/en-us/azure/key-vault/certificates/tutorial-import-certificate?tabs=azure-portal


## Enable Nginx in Kubernetes

1. Enable Nginx
```
az aks approuting enable --resource-group yuwzho-acme --name yuwzho-acme-k8s

KEYVUALT_ID=$(az keyvault show --name yuwzho-acme-kv --query id --output tsv)
az aks approuting update --resource-group yuwzho-acme --name yuwzho-acme-k8s --nginx External --enable-kv --attach-kv ${KEYVUALT_ID}
```

1. Retrieve the Nginx public IP and note the "EXTERNAL-IP"

```
kubectl get svc nginx -n app-routing-system
```

1. Go to your DNS zone to add A record to point the domain in your TLS cert to the external IP you obtained.