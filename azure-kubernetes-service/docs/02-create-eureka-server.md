## Introduction

In this guide, you will learn how to create and deploy a Eureka Server on Azure Kubernetes Service (AKS). Eureka Server is a service registry that allows microservices to register themselves and discover other registered services. See more details in [Service Discovery: Eureka Server](https://cloud.spring.io/spring-cloud-netflix/multi/multi_spring-cloud-eureka-server.html).

## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Maven
- Azure CLI
- Docker

## Outputs

By the end of this guide, you will have a running Eureka Server on your AKS cluster.

## Steps

### Prepare the Eureka Server Image

1. **Setup variables**
   
   Set up the variables used to deploy Eureka Server
   ```bash
   source resources/var.sh
   echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
   echo "AKS_NAME=${AKS_NAME}"
   echo "ACR_NAME=${ACR_NAME}"
   echo "EUREKA_IMAGE_TAG=${EUREKA_IMAGE_TAG}"
   ```

1. **Package the Eureka Server**

   Go to folder `azure-kubernetes-service/resources/eureka/eureka-server` in this project, build the eureka server package:

   ```bash
   cd azure-kubernetes-service/resources/eureka/eureka-server
   mvn clean package -DskipTests
   ```

1. **Build the docker image**
  
   Use Azure Container Build to build the Eureka image. For more details of the ACR build, see [Automate container image builds and maintenance with Azure Container Registry tasks](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview).

   ```azurecli
   az acr build --registry ${ACR_NAME} --image eureka-server:${EUREKA_IMAGE_TAG} target/docker
   ```

### Deploy the Eureka Server

1. **Edit the Kubernetes Resource File**

   Locate the `eureka-server.yaml` file in the `azure-kubernetes-service/resources/eureka` directory. Edit the following code snippet.

   - **`<eureka-image-tag>`**: Update to the value of `${EUREKA_IMAGE_TAG}`
   - **`<acr-name>`**: Update to the value of `${ACR_NAME}`

   ```yaml
      containers:
      - name: eureka-server
        image: "<acr-name>.azurecr.io/eureka-server:<eureka-image-tag>"
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

## Next Steps

- Follow [03-create-config-server](./03-create-config-server.md) to create and deploy a Spring Cloud Config Server on Azure Kubernetes Service.

