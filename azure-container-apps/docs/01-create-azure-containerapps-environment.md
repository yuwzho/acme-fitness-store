# Create Azure Container Apps Environment
## Introduction
This document provides a step-by-step guide to create an Azure Container Apps Environment.

## Prerequisites
- Install Azure CLI. For instructions, refer to [Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- Azure subscription.
- Install or update the Azure Container Apps extension for the Azure CLI:
    ```bash
    az extension add --name containerapp --upgrade
    ```
- Register the `Microsoft.App` and `Microsoft.OperationalInsights` namespaces:
    ```bash
    az provider register --namespace Microsoft.App
    az provider register --namespace Microsoft.OperationalInsights
    ```

## Outputs
- Azure Container Apps Environment.

## Steps

### 1. Clone the repo
Create a new folder and clone the sample app repository:
```shell
git clone https://github.com/Azure-Samples/acme-fitness-store.git
cd acme-fitness-store
```

### 2. Set Variables
1. Create environment variables file setup-env-variables.sh based on template.
```bash
cp azure-container-apps/scripts/setup-env-variables-template.sh setup-env-variables.sh -i
```

2. Update below resource information in `setup-env-variables.sh`:
```
SUBSCRIPTION='subscription-id'                 # replace it with your subscription-id
PREFIX='unique-prefix'                         # unique prefix for all resources(not use special characters)
```

2. Set up the variables for your environment:
```bash
source setup-env-variables.sh
az account set --subscription ${SUBSCRIPTION}

echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
echo "ENVIRONMENT=${ENVIRONMENT}"
echo "LOCATION=${LOCATION}"
```

### 3. Create Resource Group
Create a resource group to host all the Azure resources:
```bash
az group create \
    --name ${RESOURCE_GROUP} \
    --location ${LOCATION}
```

### 4. Create Azure Container Apps Environment
Create an Azure Container Apps Environment with system assigned managed identity:
```bash
az containerapp env create \
    --name ${ENVIRONMENT} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${LOCATION} \
    --mi-system-assigned
```

## Next Steps

- Follow [02-create-config-server](./02-create-config-server.md) to create and deploy a Config Server on Azure Container Apps Environment.