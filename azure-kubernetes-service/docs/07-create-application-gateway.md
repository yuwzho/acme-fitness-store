## Prerequisites

- An existing Azure Kubernetes Service (AKS) cluster.

## Prepare the Spring Cloud Gateway Image

1. **Clone the Repository**

   The code is under `resources/gateway/gateway`. Enter the directory, there is also a `Dockerfile`.

1. **Configure the Spring Cloud Gateway**

   The configuration of Spring Cloud Gateway and routes are under `resources/gateway/gateway/src/main/resources/application.yaml`. Please refer to [Spring Cloud Gateway document](https://docs.spring.io/spring-cloud-gateway/reference/spring-cloud-gateway/request-predicates-factories.html) for route configuration.

1. **Build and Push the Docker Image**

    ```azurecli
    az acr build --image $GATEWAY_IMAGE_TAG --registry $ACR_NAME --file Dockerfile . --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION
    ```

    Replace the `GATEWAY_IMAGE_TAG`, `ACR_NAME`, `RESOURCE_GROUP` and `SUBSCRIPTION`.


## Deploy the Spring Cloud Gateway Image in AKS

1. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --subscription $AKS_SUBSCRIPTION_ID --admin
   ```

1. **Locate the Kubernetes Resource File**

   Find the `gateway.yaml` file in the `resources/gateway` directory, replace the Spring Cloud Gateway tag accordingly.

1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the eureka server:

   ```bash
   kubectl apply -f gateway.yaml
   ```

   It creates gateway deployment, service and ingress.

1. **Verify the Deployment**

   Wait for the pod to start running. You can check the status with:

   ```bash
   kubectl get pods
   ```

   You should see output similar to:

    ```
   NAME                                   READY   STATUS    RESTARTS   AGE
   asc-scg-default-7656c865bb-4db2p       1/1     Running   0          3m
   ```
