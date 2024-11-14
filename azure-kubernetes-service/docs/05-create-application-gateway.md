## Introduction

In this guide, you will learn how to create and deploy a Spring Cloud Gateway on Azure Kubernetes Service (AKS). Spring Cloud Gateway provides a library for building an API Gateway on top of Spring WebFlux. For more details, refer to the [Spring Cloud Gateway documentation](https://spring.io/projects/spring-cloud-gateway).

## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service, Azure Container Registry, and Azure Keyvault.
- Maven
- Azure CLI
- Docker
- TLS cert stored in the Azure Keyvault.

## Outputs

By the end of this guide, you will have a running Spring Cloud Gateway on your AKS cluster.

## Steps

### Prepare the Spring Cloud Gateway Image

1. **Setup variables**

   Set up the variables used to deploy Spring Cloud Gateway:

   ```bash
   source resources/var.sh
   az account set -s ${SUBSCRIPTION}

   echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
   echo "AKS_NAME=${AKS_NAME}"
   echo "ACR_NAME=${ACR_NAME}"
   echo "KEYVAULT_NAME=${KEYVAULT_NAME}"
   echo "GATEWAY_IMAGE_TAG=${GATEWAY_IMAGE_TAG}"
   ```

2. **Get the code**

   The code is under `resources/gateway/gateway`. Enter the directory, there is also a `Dockerfile`.

3. **Configure the Spring Cloud Gateway**

   The configuration of Spring Cloud Gateway and routes are under `resources/gateway/gateway/src/main/resources/application.yaml`. Please refer to [Spring Cloud Gateway document](https://docs.spring.io/spring-cloud-gateway/reference/spring-cloud-gateway/request-predicates-factories.html) for route configuration.

4. **Build and Push the Docker Image**

   ```azurecli
   az acr build --image ${GATEWAY_IMAGE_TAG} --registry ${ACR_NAME} --file Dockerfile . --resource-group ${RESOURCE_GROUP}
   ```

### Deploy the Spring Cloud Gateway Image in AKS

1. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --admin
   ```

2. **Edit the Kubernetes Resource File**

   Locate the `gateway.yaml` file in the `resources/gateway` directory. Edit the following code snippet:

   - **`<gateway-image-tag>`**: Update to the value of `${GATEWAY_IMAGE_TAG}`
   - **`<acr-name>`**: Update to the value of `${ACR_NAME}`
   - **`<keyvault-name>`**: Update to the value of `${KEYVAULT_NAME}`
   - **`<tls-cert-name>`**: Update to your TLS cert name.
   - **`<spring-cloud-gateway-host>`**: Update to the host name for your Spring Cloud Gateway, the domain should be consistent with the Subject Name configured in the TLS cert.

   > `https://<keyvault-name>.vault.azure.net/certificates/<tls-cert-name>` should point to a valid certificate.

3. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the Spring Cloud Gateway:

   ```bash
   kubectl apply -f gateway.yaml
   ```

   It creates gateway deployment, service, and ingress.

4. **Verify the Deployment**

   Wait for the pod to start running. You can check the status with:

   ```bash
   kubectl get pods
   ```

   You should see output similar to:

   ```
   NAME                                   READY   STATUS    RESTARTS   AGE
   gateway-deployment-7656c865bb-4db2p    1/1     Running   0          3m
   ```

   **Tip**: If the pod is not running, check for errors using:

   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

5. **Verify the hostname**

   Open the `<spring-cloud-gateway-host>` you configured in the `gateway.yaml`, you should see a 404 page. After deploying the backend application, this link will show the application page.

## Next Steps

- Follow [06-create-application-supporting-service](./06-create-application-supporting-service.md) to set up the supporting services for your applications, including PostgreSQL and Redis Cache.
