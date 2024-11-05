---
Onwer: Yuwei
Output:
  - Create ACR
  - Create AKS that connects to the ACR
  - Create Key Vault
  - Create Ingress with CA cert
---

1. Create RG
`az group create -n yuwzho-acme -l eastus2`
1. Create ACR
`az acr create -g yuwzho-acme -n acmeacr --sku Premium`

1. Enable 
`az feature register --namespace Microsoft.Compute --name EncryptionAtHost`

1. Create AKS

```
az aks create \
    -g  yuwzho-acme \
    -n yuwzho-acme-aks \
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
    --node-vm-size Standard_D4as_v4
```

```
az aks nodepool add \
    --cluster-name yuwzho-acme-aks \
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
    --cluster-name yuwzho-acme-aks \
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
az aks get-credentials --resource-group yuwzho-acme --name yuwzho-acme-aks --overwrite-existing
```
