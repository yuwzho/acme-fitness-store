

This guide shows you how to build the polyglot applications using Pack CLI on your local development machine.

## Install Pack CLI

For instructions to install Pack CLI, refer to [Pack CLI installation guide](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/).

## Clone the repo

```bash
mkdir source-code
cd source-code
git clone https://github.com/Azure-Samples/acme-fitness-store
cd acme-fitness-store
```

## Build applications


```bash
export AI_APP=acme-assist
export CATALOG_SERVICE_APP=acme-catalog
export IDENTITY_SERVICE_APP=acme-identity
export PAYMENT_SERVICE_APP=acme-payment
export ORDER_SERVICE_APP=acme-order
export CART_SERVICE_APP=acme-cart
export FRONTEND_APP=acme-shopping
export CONTAINER_REGISTRY=acmeacr.azurecr.io   # e.g. myacr.azurecr.io/acme-fitness-store, myname/acme-fitness-store
export IMAGE_TAG=buildpack-1

# Build Assist app
pack build ${CONTAINER_REGISTRY}/${AI_APP}:${IMAGE_TAG} --path apps/acme-assist \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17
# Build Catalog Service
pack build ${CONTAINER_REGISTRY}/${CATALOG_SERVICE_APP}:${IMAGE_TAG} --path apps/acme-catalog \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17
# Build Identity Service
pack build ${CONTAINER_REGISTRY}/${IDENTITY_SERVICE_APP}:${IMAGE_TAG} --path apps/acme-identity \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17
# Build Payment Service
pack build ${CONTAINER_REGISTRY}/${PAYMENT_SERVICE_APP}:${IMAGE_TAG} --path apps/acme-payment \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17
# Build Order Service
pack build ${CONTAINER_REGISTRY}/${ORDER_SERVICE_APP}:${IMAGE_TAG} --path apps/acme-order \
    --builder paketobuildpacks/builder-jammy-base
# Build Cart Service
pack build ${CONTAINER_REGISTRY}/${CART_SERVICE_APP}:${IMAGE_TAG} --path apps/acme-cart \
    --builder paketobuildpacks/builder-jammy-base
# Build Frontend App
pack build ${CONTAINER_REGISTRY}/${FRONTEND_APP}:${IMAGE_TAG} --path apps/acme-shopping \
    --builder paketobuildpacks/builder-jammy-base


# Login the ACR
az acr login -n acmeacr

# Push Docker images to container registry
docker push ${CONTAINER_REGISTRY}/${AI_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${CATALOG_SERVICE_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${IDENTITY_SERVICE_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${PAYMENT_SERVICE_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${ORDER_SERVICE_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${CART_SERVICE_APP}:${IMAGE_TAG}
docker push ${CONTAINER_REGISTRY}/${FRONTEND_APP}:${IMAGE_TAG}
```
