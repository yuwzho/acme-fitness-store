## Introduction
This document provides a step-by-step guide to create an Azure Kubernetes Service (AKS) cluster, integrate it with Azure Container Registry (ACR), and set up Azure Key Vault and Nginx ingress with a CA certificate.

## Prerequisites
- Azure CLI installed
- Azure subscription
- Sufficient permissions to create resources in the Azure subscription
    - **Contributor** - Creates resource and all other Azure resources
    - **User Access Administrator** - Assign ncessary 

## Outputs
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) connected to ACR
- Azure Key Vault
- Nginx ingress with CA certificate

## Steps

### 1. Set Variables
```
RESOURCE_GROUP="yuwzho-acme"
AKS_NAME="${RESOURCE_GROUP}-k8s"
ACR_NAME="acmeacr"
KEYVAULT_NAME="${RESOURCE_GROUP}-kv"
WORKSPACE_NAME="${RESOURCE_GROUP}-workspace"

echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
echo "AKS_NAME=${AKS_NAME}"
echo "ACR_NAME=${ACR_NAME}"
echo "KEYVAULT_NAME=${KEYVAULT_NAME}"
echo "WORKSPACE_NAME=${WORKSPACE_NAME}"
```

### 2. Create Resource Group
1. Create resource group to host all the Azure resources.
```bash
az group create -n ${RESOURCE_GROUP} -l eastus2
```

### 3. Create Azure Container Registry
Create Azure Container Registry (ACR). This ACR will be used:
- Build application components
- Store application images built by buildpack

```bash
az acr create -g ${RESOURCE_GROUP} -n ${ACR_NAME} --sku Premium
```

### 4. Create AKS
1. Enable `EncryptionAtHost`, may take 10+ minutes to finish
```bash
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
```

Run `az feature register --namespace Microsoft.Compute --name EncryptionAtHost` to wait it state to `Registered`.

1. Create workspace
```
az monitor log-analytics workspace create --resource-group ${RESOURCE_GROUP} --workspace-name ${WORKSPACE_NAME}
```

1. Create AKS. 
   Below commands guide you create the AKS. For more information on the features enabled in the AKS cluster, refer to the following documentations:

    - [Attach Azure Container Registry to AKS](https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration)
    - [Enable Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
    - [Azure Load Balancer SKU](https://learn.microsoft.com/en-us/azure/load-balancer/skus)
    - [Cluster Autoscaler](https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler)
    - [Network concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
    - [Encryption at Host](https://learn.microsoft.com/en-us/azure/aks/enable-host-encryption)
    - [Outbound Type](https://learn.microsoft.com/en-us/azure/aks/egress-outboundtype)
    - [Node pools](https://learn.microsoft.com/en-us/azure/aks/create-node-pools)
    - [Storage concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-storage)
    - [Monitor AKS](https://learn.microsoft.com/en-us/azure/aks/monitor-aks)


    ```
    WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group ${RESOURCE_GROUP} --workspace-name ${WORKSPACE_NAME} --query id -o tsv)
    ```

    ```
    az aks create \
        -g  ${RESOURCE_GROUP} \
        -n ${AKS_NAME} \
        --attach-acr ${ACR_NAME} \
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
    az aks nodepool add \
        --cluster-name ${AKS_NAME} \
        -g ${RESOURCE_GROUP} \
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
        --cluster-name ${AKS_NAME} \
        -g ${RESOURCE_GROUP} \
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

1. Retrieve access token. This command get the admin access for the AKS cluster. For more access management, see https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac?tabs=portal

    ```
    az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --overwrite-existing --admin
    ```

1. Install or update the kubectl CLI
    ```
    az aks install-cli
    ```

1. Verify you can connect to the AKS

    ```
    kubectl get ns
    ```

### 5. Create Azure Keyvault and cert

1. Get AKS outbound IPs and record these IPs as `<AKS-outbound-ip>`
    ```
    az aks show -g  ${RESOURCE_GROUP} -n ${AKS_NAME} --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
    az resource show --ids <the ID from previous output> --query properties.ipAddress -o tsv
    ```

1. Get AKS Vnet IDs
    ```
    NODE_RESOURCE_GROUP=$(az aks show --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --query nodeResourceGroup -o tsv)
    az resource list --resource-type microsoft.network/virtualnetworks -g ${NODE_RESOURCE_GROUP} --query "[?starts_with(name, 'aks-vnet')].name" -o tsv
    ```

    List all subnet under the vnet, record these ids are `<subnet-ids>`
    ```
    az network vnet subnet list --resource-group ${NODE_RESOURCE_GROUP} --vnet-name <vnetName> --query "[].id" -o tsv
    ```

1. Create Azure KeyVault
`az keyvault create --resource-group ${RESOURCE_GROUP} --name ${KEYVAULT_NAME} --network-acls-ips <AKS-outbound-ip> --network-acls-vnets <subnet-ids>`

1. Assign access to yourself
    ```
    # Get your Azure AD user ID
    USER_ID=$(az ad signed-in-user show --query id --output tsv)
    KEYVUALT_ID=$(az keyvault show --name ${KEYVAULT_NAME} --query id --output tsv)
    # Assign yourself the necessary permissions
    az role assignment create --role "Key Vault Certificates Officer" --assignee ${USER_ID} --scope ${KEYVUALT_ID}
    ```

1. Create a self-signed certificate or import your CA cert to the Keyvault, ref: https://learn.microsoft.com/en-us/azure/key-vault/certificates/tutorial-import-certificate?tabs=azure-portal
  > Here suggest to create a wildcard domain cert, like `*.demo.com`.

### 6. Enable Nginx in Kubernetes
Below steps guide how to enable the Nginx as add-on in the AKS cluster. For more details can view [Managed NGINX ingress with the application routing add-on](https://learn.microsoft.com/en-us/azure/aks/app-routing).

1. Enable Nginx
    ```
    az aks approuting enable --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME}

    KEYVUALT_ID=$(az keyvault show --name ${KEYVAULT_NAME} --query id --output tsv)
    az aks approuting update --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --nginx External --enable-kv --attach-kv ${KEYVUALT_ID}
    ```

1. Retrieve the Nginx public IP and note the "EXTERNAL-IP"

    ```
    kubectl get svc nginx -n app-routing-system
    ```

1. Go to your DNS zone to add record.
   - Add A record to point the domain in your TLS cert to the external IP you obtained. E.g. `demo.com` points to the IP address.
   - Add a wildcard CName record to the A record. E.g. `*.demo.com` points to the `demo.com`