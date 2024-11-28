# Integrate with Azure Database for PostgreSQL and Azure Cache for Redis
## Introduction
By default, several services use in-memory data storage. And in this guide, you will learn how to create persistent stores outside the applications and connect applications to those stores.

## Prerequisites
- Completion of [06-create-gateway-server](./06-create-gateway-server.md).
- Install or update the Service Connector Passwordless extension for the Azure CLI:
```bash
  az extension add --name serviceconnector-passwordless --upgrade
  ```

## Outputs
By the end of this guide, you will have an Azure Database for PostgreSQL and an Azure Cache for Redis connected with container apps.

## Steps

### 1. Verify Variables
Verify the variables to prepare database and cache:
```bash
source setup-env-variables.sh

echo "AZURE_CACHE_NAME=${AZURE_CACHE_NAME}"
echo "POSTGRES_SERVER_NAME=${POSTGRES_SERVER_NAME}"
echo "CATALOG_SERVICE_DB=${CATALOG_SERVICE_DB}"
echo "CART_SERVICE_CACHE_CONNECTION=${CART_SERVICE_CACHE_CONNECTION}"
echo "CATALOG_SERVICE_PSQL_CONNECTION=${CATALOG_SERVICE_PSQL_CONNECTION}"
```

### 2. Create Azure Cache for Redis for Cart Service
1. Create an instance of Azure Cache for Redis:
```bash
az redis create \
    --name $AZURE_CACHE_NAME \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP \
    --sku Basic \
    --vm-size c0
```
2. Bind cart service to Redis Cache:
```bash
az containerapp connection create redis \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CART_SERVICE_APP} \
    --connection ${CART_SERVICE_CACHE_CONNECTION} \
    --container ${CART_SERVICE_APP} \
    --tg ${RESOURCE_GROUP} \
    --server ${AZURE_CACHE_NAME} \
    --database 0 \
    --client-type python \
    --secret
```
3. Validate the connection to the Azure Cache for Redis:
```bash
az containerapp connection validate \
    -g ${RESOURCE_GROUP} \
    -n ${CART_SERVICE_APP} \
    --connection ${CART_SERVICE_CACHE_CONNECTION} \
    --output table
```
4. Retrieve the Redis connection string and update the Cart Service:
```bash
export REDIS_CONN_STR=$(az containerapp connection show \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CART_SERVICE_APP} \
    --connection ${CART_SERVICE_CACHE_CONNECTION} \
    --query configurations[0].value \
    -o tsv)

az containerapp update \
    --name ${CART_SERVICE_APP} \
    --resource-group ${RESOURCE_GROUP} \
    --set-env-vars "CART_PORT=8080" "REDIS_CONNECTIONSTRING=${REDIS_CONN_STR}" "AUTH_URL=https://${GATEWAY_URL}"
```

### 3. Create Azure Database for PostgreSQL for Order and Catalog Services
1. Create an instance of Azure Database for PostgreSQL:
```bash
az postgres flexible-server create \
    --name ${POSTGRES_SERVER_NAME} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${LOCATION} \
    --public-access 0.0.0.0 \
    --tier Burstable \
    --sku-name Standard_B1ms \
    --version 14 \
    --storage-size 32 \
    --active-directory-auth Enabled
```
2. Create a database for the catalog service:
```bash
az postgres flexible-server db create \
    --resource-group ${RESOURCE_GROUP} \
    --database-name ${CATALOG_SERVICE_DB} \
    --server-name ${POSTGRES_SERVER_NAME}
```
3. Bind catalog service to Postgres:
```bash
az containerapp connection create postgres-flexible \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CATALOG_SERVICE_APP} \
    --connection ${CATALOG_SERVICE_PSQL_CONNECTION} \
    --container ${CATALOG_SERVICE_APP} \
    --target-resource-group ${RESOURCE_GROUP} \
    --server ${POSTGRES_SERVER_NAME} \
    --database ${CATALOG_SERVICE_DB} \
    --system-identity \
    --client-type springboot
```
4. Validate the connection to the Azure Database for PostgreSQL:
```bash
az containerapp connection validate \
    -g ${RESOURCE_GROUP} \
    -n ${CATALOG_SERVICE_APP} \
    --connection ${CATALOG_SERVICE_PSQL_CONNECTION} \
    --output table
```

## Next Steps

- Follow [08-create-admin-server](./08-create-admin-server.md) to create an admin server on Azure Container Apps Environment.