# Containerize Application

## Introduction

This guide shows you how to build polyglot applications using Pack CLI on your local development machine and push them to Azure Container Registry (ACR).

Buildpacks provide a higher-level abstraction for building container images. They take your application source code and transform it into a container image without the need for a Dockerfile. This process involves detecting the type of application, compiling the code, and packaging it with the necessary runtime dependencies. Buildpacks are particularly useful for polyglot environments where multiple languages and frameworks are used, as they can automatically handle the specifics of each technology stack. For more information, refer to the [official Buildpacks documentation](https://buildpacks.io/docs/).

## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Container Registry.
- Install Pack CLI. For instructions, refer to the [Pack CLI installation guide](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/).
- Install Azure CLI. For instructions, refer to the [Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- Docker installed on your local machine.

## Outputs

- Docker images for each application pushed to your ACR.

## Steps

### 1. Set up variables

Set up the variables used to build the container image:
```bash
source resources/var.sh
az account set -s ${SUBSCRIPTION}

echo "ACR_NAME=${ACR_NAME}"
echo "CATALOG_SERVICE_APP_IMAGE_TAG=${CATALOG_SERVICE_APP_IMAGE_TAG}"
echo "PAYMENT_SERVICE_APP_IMAGE_TAG=${PAYMENT_SERVICE_APP_IMAGE_TAG}"
echo "ORDER_SERVICE_APP_IMAGE_TAG=${ORDER_SERVICE_APP_IMAGE_TAG}"
echo "CART_SERVICE_APP_IMAGE_TAG=${CART_SERVICE_APP_IMAGE_TAG}"
echo "FRONTEND_APP_IMAGE_TAG=${FRONTEND_APP_IMAGE_TAG}"
```

### 2. Build applications

The following commands will build each application using the Pack CLI and the Paketo Buildpacks builder. Each application will be built with the necessary runtime dependencies and tagged with the specified image tag. The built images will then be pushed to the Azure Container Registry.
> Note: open your Docker environment to build and push the images to ACR.
```bash
CATALOG_SERVICE_APP=acme-catalog
PAYMENT_SERVICE_APP=acme-payment
ORDER_SERVICE_APP=acme-order
CART_SERVICE_APP=acme-cart
FRONTEND_APP=frontend
CONTAINER_REGISTRY=${ACR_NAME}.azurecr.io

# Build Catalog Service
pack build ${CONTAINER_REGISTRY}/${CATALOG_SERVICE_APP}:${CATALOG_SERVICE_APP_IMAGE_TAG} --path ../apps/acme-catalog \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17

# Build Payment Service
pack build ${CONTAINER_REGISTRY}/${PAYMENT_SERVICE_APP}:${PAYMENT_SERVICE_APP_IMAGE_TAG} --path ../apps/acme-payment \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17

# Build Order Service
pack build ${CONTAINER_REGISTRY}/${ORDER_SERVICE_APP}:${ORDER_SERVICE_APP_IMAGE_TAG} --path ../apps/acme-order \
    --builder paketobuildpacks/builder-jammy-base

# Build Cart Service
pack build ${CONTAINER_REGISTRY}/${CART_SERVICE_APP}:${CART_SERVICE_APP_IMAGE_TAG} --path ../apps/acme-cart \
    --builder paketobuildpacks/builder-jammy-base

# Build Frontend App
pack build ${CONTAINER_REGISTRY}/${FRONTEND_APP}:${FRONTEND_APP_IMAGE_TAG} --path ../apps/acme-shopping \
    --builder paketobuildpacks/builder-jammy-base
```

### 3. Push image to ACR
# Login the ACR
```azurecli
az acr login -n ${ACR_NAME}
```

# Push Docker images to container registry
```bash
docker push ${CONTAINER_REGISTRY}/${CATALOG_SERVICE_APP}:${CATALOG_SERVICE_APP_IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${PAYMENT_SERVICE_APP}:${PAYMENT_SERVICE_APP_IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${ORDER_SERVICE_APP}:${ORDER_SERVICE_APP_IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${CART_SERVICE_APP}:${CART_SERVICE_APP_IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${FRONTEND_APP}:${FRONTEND_APP_IMAGE_TAG}
```

## Next Steps

- Follow [08-01-deploy-frontend-application](./08-01-deploy-frontend-application.md) to deploy the Acme Frontend application and connect it to Spring Cloud Gateway.
