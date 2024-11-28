# Create Config Server for Spring
## Introduction
In this guide, you will learn how to create a Config Server for Spring component on Azure Container Apps Environment. The Config Server for Spring provides a centralized location to make configuration data available to multiple applications. For more information on using Config Server for Spring component, refer to the [official documentation](https://learn.microsoft.com/azure/container-apps/java-config-server-usage).

## Prerequisites
- Completion of [01-create-azure-containerapps-environment](./01-create-azure-containerapps-environment.md).

## Outputs
By the end of this guide, you will have a running Config Server for Spring component on your Azure Container Apps Environment.

## Steps

### 1. Verify Variables
Verify the variables to create Config Server:
```bash
source setup-env-variables.sh

echo "CONFIG_COMPONENT_NAME=${CONFIG_COMPONENT_NAME}"
echo "CONFIG_SERVER_GIT_URI=${CONFIG_SERVER_GIT_URI}"
```

### 2. Create Config Server for Spring Java component
Create a Config Server on the existing Azure Container Apps Environment:
```bash
az containerapp env java-component config-server-for-spring create \
    --environment ${ENVIRONMENT} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CONFIG_COMPONENT_NAME} \
    --min-replicas 1 \
    --max-replicas 1 \
    --configuration spring.cloud.config.server.git.uri=${CONFIG_SERVER_GIT_URI}
```

## Next Steps

- Follow [03-create-eureke-server](./03-create-eureke-server.md) to create a eureka server on Azure Container Apps Environment.