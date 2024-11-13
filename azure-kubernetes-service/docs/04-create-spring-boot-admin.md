## Introduction

In this guide, you will learn how to create and deploy a Spring Boot Admin server on Azure Kubernetes Service (AKS). Spring Boot Admin is used to manage and monitor Spring Boot applications. For more details, refer to the [Spring Boot Admin documentation](https://docs.spring-boot-admin.com/3.0.0/getting-started.html).

## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service, Azure Container Registry and Azure Keyvault.
- Maven
- Azure CLI
- Docker
- TLS cert stored in the Azure Keyvault.

## Outputs

By the end of this guide, you will have a running Spring Boot Admin server on your AKS cluster.

## Steps

### Prepare the Spring Boot Admin Server Image

1. **Setup variables**
   
   Set up the variables used to deploy Spring Boot Admin Server:
   ```bash
   RESOURCE_GROUP="yuwzho-acme"
   AKS_NAME="${RESOURCE_GROUP}-k8s"
   ACR_NAME="acmeacr"
   KEYVAULT_NAME="${RESOURCE_GROUP}-kv"
   SPRING_BOOT_ADMIN_IMAGE_TAG="acrbuild-spring-boot-admin"

   echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
   echo "AKS_NAME=${AKS_NAME}"
   echo "ACR_NAME=${ACR_NAME}"
   echo "SPRING_BOOT_ADMIN_IMAGE_TAG=${SPRING_BOOT_ADMIN_IMAGE_TAG}"
   ```

1. **Package the Spring Boot Admin Server**

   Go to folder `azure-kubernetes-service/resources/spring-boot-admin` in this project, build the Spring Boot Admin server package:

   ```bash
   cd azure-kubernetes-service/resources/spring-boot-admin
   mvn clean package -DskipTests
   ```

   For more details to create a Spring Boot Admin server, follow the [Getting Started documentation](https://docs.spring-boot-admin.com/3.0.0/getting-started.html). To register client applications, you may use Spring Cloud Discovery instead of the Spring Boot Admin Client. This approach does not require modifications to your applications' configurations.

1. **Build the docker image**
  
   Use Azure Container Build to build the Spring Boot Admin image. For more details of the ACR build, see [Automate container image builds and maintenance with Azure Container Registry tasks](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview).

   ```azurecli
   az acr build --registry ${ACR_NAME} --image spring-boot-admin:${SPRING_BOOT_ADMIN_IMAGE_TAG} target/docker
   ```

### Deploy the Spring Boot Admin Server

1. **Edit the Kubernetes Resource File**

   Locate the `spring-boot-admin.yaml` file in the `azure-kubernetes-service/resources/spring-boot-admin` directory. Edit the following code snippet.

   - **`<spring-boot-admin-image-tag>`**: Update to the value of `${SPRING_BOOT_ADMIN_IMAGE_TAG}`
   - **`<acr-name>`**: Update to the value of `${ACR_NAME}`
   - **`<keyvault-name>`**: Update to the value of `${KEYVAULT_NAME}`.
   - **`<tls-cert-name>`**: Update to your TLS cert name.
   - **`<spring-boot-admin-host>`**: Update to the host name for your Spring Boot Admin server, the domain should be consistent with the Subject Name configured in the TLS cert.

   > `https://<keyvault-name>.vault.azure.net/certificates/<tls-cert-name>` should point to a valid certificate.


1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the Spring Boot Admin server:

   ```bash
   kubectl apply -f spring-boot-admin.yaml
   ```

1. **Verify the Deployment**

   Wait for the pod to start running. You can check the status with:

   ```bash
   kubectl get pods
   ```

   You should see output similar to:

   ```
   NAME                                   READY   STATUS    RESTARTS   AGE
   spring-boot-admin-84f88cfb96-fqqws     1/1     Running   0          20s
   ```

   **Tip**: If the pod is not running, check for errors using:
  
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

1. **Verify the hostname**

   Open the `<spring-boot-admin-host>` you configured in the `spring-boot-admin.yaml`, you should see the Spring Boot Admin dashboard.
