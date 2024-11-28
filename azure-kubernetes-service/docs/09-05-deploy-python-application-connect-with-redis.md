## Introduction

In this guide, we will walk you through the process of deploying the Acme Cart application to an Azure Kubernetes Service and connecting it to a Redis cache. To connect the application on AKS to Redis, it uses the workload identity feature on AKS. See details in [Workload Identity Deploy Cluster](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster).

## Prerequisites

Before you begin, ensure you have the following:

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Follow [07-containerize-application](./08-containerize-application.md) to build the image and push to the Azure Container Registry.
- Follow [06-create-application-supporting-service](./06-create-application-supporting-service.md) to set up the Redis cache.

## Outputs

After completing this guide, you will have:

- Deployed the Acme Cart application to your Kubernetes cluster.
- Configured the application to connect to Redis using Workload Identity.
- Exposed the application within the cluster.

## Steps

1. **Set up the variables**
   Set up the variables used for image and Redis:
   ```bash
   source resources/var.sh
   az account set -s ${SUBSCRIPTION}

   IDENTITY_NAME=acme-cart-identity

   echo ACR_NAME=${ACR_NAME}
   echo CART_SERVICE_APP_IMAGE_TAG=${CART_SERVICE_APP_IMAGE_TAG}
   echo IDENTITY_NAME=${IDENTITY_NAME}
   ```

1. **Create managed identity**

   Create the managed identity for the cart service:
   ```bash
   az identity create -n ${IDENTITY_NAME} -g ${RESOURCE_GROUP} --location ${LOCATION} --subscription ${SUBSCRIPTION}
   ```

1. **Assign Redis access to the identity**

   Assign the managed identity access to the Redis cache:
   ```bash
   OBJECT_ID=$(az identity show -n ${IDENTITY_NAME} -g ${RESOURCE_GROUP} --query principalId -o tsv)
   az redis access-policy-assignment create \
       --access-policy-name "Data Owner"  \
       -n ${REDIS_NAME} \
       -g ${RESOURCE_GROUP} \
       --object-id ${OBJECT_ID} \
       --object-id-alias ${IDENTITY_NAME} \
       --policy-assignment-name ${OBJECT_ID}
   ```

1. **Add federated credential for managed identity**

   Add federated credential for the managed identity:
   ```bash
   AKS_OIDC_ISSUER=$(az aks show --name ${AKS_NAME} \
       --resource-group ${RESOURCE_GROUP} \
       --query "oidcIssuerProfile.issuerUrl" \
       --output tsv)

   az identity federated-credential create \
       --name cart_acme_redis \
       --identity-name ${IDENTITY_NAME} \
       --resource-group ${RESOURCE_GROUP} \
       --issuer "${AKS_OIDC_ISSUER}" \
       --subject system:serviceaccount:default:sa-account-redis-cart \
       --audience api://AzureADTokenExchange
   ```

1. **Retrieve the connection information**

   Retrieve the necessary values:
   ```bash
   CLIENT_ID=$(az identity show -n ${IDENTITY_NAME} -g ${RESOURCE_GROUP} --query clientId -o tsv)
   REDIS_HOSTNAME=$(az redis show -n ${REDIS_NAME} -g ${RESOURCE_GROUP} --query hostName -o tsv)

   echo CLIENT_ID=${CLIENT_ID}
   echo REDIS_HOSTNAME=${REDIS_HOSTNAME}
   echo OBJECT_ID=${OBJECT_ID}
   echo ACR_NAME=${ACR_NAME}
   echo CART_SERVICE_APP_IMAGE_TAG=${CART_SERVICE_APP_IMAGE_TAG}
   ```

1. **Edit the resource file**

   Locate the `resources/applications/acme-cart.yml` file and update the following placeholders:

   - **`<client-id>`**: Update to the value of `${CLIENT_ID}`.
   - **`<redis-host>`**: Update to the value of `${REDIS_HOSTNAME}`.
   - **`<redis-user-name>`**: Update to the value of `${OBJECT_ID}`
   - **`<acr-name>`**: Update to the name of your Azure Container Registry, should be the value of `${ACR_NAME}`.
   - **`<cart-service-app-image-tag>`**: Update to the tag of your application image, should be the value of `${CART_SERVICE_APP_IMAGE_TAG}`.

   This command will create the following Kubernetes resources:

   1. **ServiceAccount**: `sa-account-redis-cart`
      - Used by the cart application to authenticate with the managed identity.

   2. **ConfigMap**: `cart-config`
      - Stores configuration data for the cart service.
      - Contains environment variables such as `CART_PORT` to describe the application should serve on which port.
      - Contains environment variables such as `REDIS_HOST` and `REDIS_USERNAME` to describe the connection information to the Redis Cache.

   3. **Deployment**: `cart`
      - Manages the deployment of the cart application.
      - Retrieves environment variables from the `cart-config` ConfigMap.
      - Uses the `sa-account-redis-cart` Service Account as identity to connect to Redis.
      - Configures probes for liveness and readiness to ensure the application is running correctly.
      - Specifies resource limits and requests for CPU, memory, and ephemeral storage.

   4. **Service**: `cart-service`
      - Exposes the cart application within the Kubernetes cluster.
      - Uses a `ClusterIP` type to provide a stable internal IP address.
      - Routes traffic on port 80 to the application's container port 8080.

1. **Deploy the acme-cart service**

   Apply the resource:
   ```bash
   kubectl apply -f resources/applications/acme-cart.yml
   ```

1. **Verify the deployment**

   Wait for the pod to start running. You can check the status with:
   ```bash
   kubectl get pods
   ```

   You should see output similar to:
   ```
   NAME                        READY   STATUS    RESTARTS   AGE
   cart-7656c865bb-4db2p       1/1     Running   0          3m
   ```

   **Tip**: If the pod is not running, check for errors using:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

1. **Verify the whole application**
   Now, all the applications are deployed. Open the Spring Cloud Gateway hostname you should view the acme-fitness-store with full functionality.

## Next Steps

- Follow [10-get-log-and-metrics](./10-get-log-and-metrics.md) to view logs and metrics for your Azure Kubernetes Service (AKS) cluster.
