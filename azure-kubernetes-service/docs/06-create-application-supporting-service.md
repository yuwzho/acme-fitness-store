## Introduction
This document provides a step-by-step guide to create supporting services for the applications, including PostgreSQL and Redis Cache.

## Azure PostgreSQL

[Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/services/postgresql/) is a managed database service that allows you to run, manage, and scale highly available PostgreSQL databases in the cloud. It offers built-in high availability, automated backups, and enterprise-grade security features. With Azure PostgreSQL, you can focus on application development without worrying about database management.

## Azure Redis Cache

[Azure Cache for Redis](https://azure.microsoft.com/en-us/services/cache/) is a fully managed, in-memory cache that enables high-performance and scalable architectures. It provides low-latency data access to improve the performance of your applications. Azure Redis Cache supports various data structures such as strings, hashes, lists, sets, and more, making it a versatile choice for caching and real-time analytics.

## Prerequisites
- Azure CLI installed
- Azure subscription
- Sufficient permissions to create resources in the Azure subscription
    - **Contributor** - Creates resource and all other Azure resources
    - **User Access Administrator** - Assign necessary roles

## Outputs
- Azure Redis Cache
- Azure PostgreSQL

## Steps

### 1. Set Variables
Set up the variables used to create the PostgreSQL and Redis:
```
source resources/var.sh

echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
echo "AKS_NAME=${AKS_NAME}"
echo "POSTGRESQL_NAME=${POSTGRESQL_NAME}"
echo "REDIS_NAME=${REDIS_NAME}"
```

### Create PostgreSQL

1. Get AKS outbound IPs and note these IPs as `<AKS-outbound-ip>`
```
az aks show -g  ${RESOURCE_GROUP} -n ${AKS_NAME} --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
az resource show --ids <the ID from previous output> --query properties.ipAddress -o tsv
```

2. Create Postgresql Flexible server and enable the access from Kubernetes
```
az postgres flexible-server create -g ${RESOURCE_GROUP} -n ${POSTGRESQL_NAME}--active-directory-auth Enabled --password-auth Disabled --public-access <AKS-outbound-ip>
```

3. Add yourself into the server admin for further settings
```
USER_ME_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv)
USER_ME_ID=$(az ad signed-in-user show --query id -o tsv)
az postgres flexible-server ad-admin create --server-name ${POSTGRESQL_NAME} --resource-group ${RESOURCE_GROUP} --display-name ${USER_ME_NAME} --object-id ${USER_ME_ID}
```

### Create Redis Cache
```
az redis create -n ${REDIS_NAME} -g ${RESOURCE_GROUP} --sku Basic --vm-size c0 -l eastus2
```

## Next Steps

- Follow [07-containerize-application](./07-containerize-application.md) to learn how to containerize your applications and push them to Azure Container Registry.