## Prerequisites

- An existing Azure Kubernetes Service (AKS) cluster.
- Maven, Docker and Azure Cli should be installed.

## Prepare the Eureka Server Image
 
1. **Package the Eureka Server**

   Go to folder `azure-kubernetes-service/resources/eureka/eureka-server` in this project, build the eureka server package:

   ```bash
   mvn clean package -DskipTests
   ```

1. **(Optional) Login to Container Registry**

   If you have not logged into your container registry, you need to login to container registry before you can push image, for example, [login to acr](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?tabs=azure-cli#log-in-to-a-registry):

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

   Run this command in your terminal or in [Azure Cloud Shell](https://azure.microsoft.com/en-us/get-started/azure-portal/cloud-shell). Replace the placeholders accordingly:
   
   ```bash
   az login
   az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --subscription $AKS_SUBSCRIPTION_ID --admin
   ```

1. **Edit the Kubernetes Resource File**

   Locate the eureka-server.yaml file in the azure-kubernetes-service/resources/eureka directory. Replace the image tag in the file with the image you just built and pushed.

   ```yaml
      containers:
      - name: eureka-server
        image: "<your-registry>.azurecr.io/eureka-server:<image-version>"
   ```

1. **Apply the Kubernetes Configuration**

   Apply the configuration using kubectl to create the Eureka Server:

   ```bash
   kubectl apply -f eureka-server.yaml
   ```

1. **Verify the Deployment**

   Use the following command to check the status of the Eureka Server pod:

   ```bash
   kubectl get pods
   ```

   If successful, you should see something like:

   ```
   NAME                                   READY   STATUS    RESTARTS   AGE
   eureka-server-867c8c97b6-nvqjx         1/1     Running   0          36m
   ```

  **Tip**: If the pod is not running, check for errors using:
  
  ```bash
  kubectl describe pod <pod-name>
  kubectl logs <pod-name>
  ```
  
## Use the Eureka Server

1. Prepare ConfigMap

   To use the Eureka Server in your applications, apply the ConfigMap configuration. Find `eureka-server-config.yaml` in the `azure-kubernetes-service/resources/eureka` directory and apply it:

   ```bash
   kubectl apply -f eureka-server-config.yaml
   ```

2. Configure Application Deployment

   Configure your applications to register with Eureka. [Here is a sample application deployment](#todo-add-link) with Eureka.
