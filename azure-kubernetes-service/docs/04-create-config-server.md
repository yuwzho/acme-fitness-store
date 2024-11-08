## Prerequisites

- An existing Azure Kubernetes Service (AKS) cluster.

## Prepare the Spring Cloud Config Server Image

1. **Clone the Repository**

   The code is under `resources\config-server`. Enter the directory, there is also a `Dockerfile`.

1. **Build and Push the Docker Image**

    ```azurecli
    az acr build --image $CONFIGSERVER_IMAGE_TAG --registry $ACR_NAME --file Dockerfile . --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION
    ```

    Replace the `CONFIGSERVER_IMAGE_TAG`, `ACR_NAME`, `RESOURCE_GROUP` and `SUBSCRIPTION`.


## Deploy the Spring Cloud Config Server Image in AKS

1. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --subscription $AKS_SUBSCRIPTION_ID --admin
   ```

1. **Locate the Kubernetes Resource File**

   Find the `configserver.yaml` file in the `resources/config-server` directory, replace the Spring Cloud Config Server image tag accordingly.

1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the eureka server:

   ```bash
   kubectl apply -f configserver.yaml
   ```

1. **Verify the Deployment**

   Wait for the pod to start running. You can check the status with:

   ```bash
   kubectl get pods
   ```

   You should see output similar to:

    ```
   NAME                                           READY   STATUS    RESTARTS   AGE
   config-server-default-6849898854-rz6md         1/1     Running   0          3m
   ```