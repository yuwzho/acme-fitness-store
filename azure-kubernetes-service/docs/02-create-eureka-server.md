## Prerequisites

- An existing Azure Kubernetes Service (AKS) cluster.

## Prepare the Eureka Server Image
 
1. **Package the Eureka Server**

   Go to folder `azure-kubernetes-service/resources/eureka/eureka-server` in this project, build the eureka server package:

   ```bash
   mvn clean package -DskipTests
   ```

1. **(Optional) Login to Container Registry**

   You may need to login to container registry before you can push image, for example, [login to acr](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-cli#log-in-to-a-registry):

   ```bash
   az login
   az acr login --name <your-registry>
   ```

1. **Build and Push the Docker Image**

   Build the Docker image and push it to your container registry (replace <your-registry> with your actual registry name):

   ```bash
   docker build -t <your-registry>/eureka-server:<image-version> .
   docker push <your-registry>/eureka-server:<image-version>
   ```

## Deploy the Eureka Server

1. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --subscription $AKS_SUBSCRIPTION_ID --admin
   ```

1. **Locate the Kubernetes Resource File**

   Find the `eureka-server.yaml` file in the `resources/eureka` directory, replace the eureka-server image tag accordingly.

1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the eureka server:

   ```bash
   kubectl apply -f eureka-server.yaml
   ```

1. **Verify the Deployment**

   Wait for the pod to start running. You can check the status with:

   ```bash
   kubectl get pods
   ```

   You should see output similar to:

   ```
   NAME                                   READY   STATUS    RESTARTS   AGE
   eureka-server-867c8c97b6-nvqjx         1/1     Running   0          36m
   ```

  Your Spring Cloud Eureka Server should now be up and running.
