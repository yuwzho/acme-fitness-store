# Create Eureka Server for Spring
## Introduction
In this guide, you will learn how to create and deploy a Eureka Server for Spring component on Azure Container Apps Environment. Eureka Server for Spring is mechanism for centralized service discovery for microservices. See more details in [official documentation](https://learn.microsoft.com/azure/container-apps/java-eureka-server-usage).

## Prerequisites
- Completion of [02-create-config-server](./02-create-config-server.md).

## Outputs
By the end of this guide, you will have a running Eureka Server for Spring component on your Azure Container Apps Environment.

## Steps

### 1. Verify variables
Verify the variables to create Eureka Server:
```bash
source setup-env-variables.sh

echo "EUREKA_COMPONENT_NAME=${EUREKA_COMPONENT_NAME}"
```

### 2. Create the Eureka Server for Spring Java component
Create a Eureka Server on the existing Azure Container Apps Environment:
```bash
az containerapp env java-component eureka-server-for-spring create \
    --environment ${ENVIRONMENT} \
    --resource-group ${RESOURCE_GROUP} \
    --name ${EUREKA_COMPONENT_NAME}
```

## Next Steps

- Follow [04-containerize-application](./04-containerize-application.md) to create a Admin Server on Azure Container Apps Environment.