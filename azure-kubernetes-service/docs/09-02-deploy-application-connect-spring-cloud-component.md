## Introduction

In this guide, we will walk you through the process of deploying the Acme Payment application to an Azure Kubernetes Service (AKS) and connecting it to deployed Spring Cloud components.

## Prerequisites

Before you begin, ensure you have the following:

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Follow [07-containerize-application](./07-containerize-application.md) to build the image and push it to the Azure Container Registry.
- Follow [02-create-eureka-server](./02-create-eureka-server.md) to create the Eureka Server for service discovery.
- Follow [03-create-config-server](./03-create-config-server.md) to create the Config Server for centralized configuration.
- Follow [04-create-spring-boot-admin](./04-create-spring-boot-admin.md) to set up Spring Boot Admin for monitoring and managing your Spring Boot applications.

## Outputs

After completing this guide, you will have:

- Deployed the Acme Payment application to your Kubernetes cluster.
- Configured the application to connect to Spring Cloud Config Server and Eureka Server.
- Exposed the application within the cluster.

## Steps

1. **Set up the variables**

   Set up the variables used for the image:
   ```bash
   source resources/var.sh
   az account set -s ${SUBSCRIPTION}

   echo ACR_NAME=${ACR_NAME}
   echo PAYMENT_SERVICE_APP_IMAGE_TAG=${PAYMENT_SERVICE_APP_IMAGE_TAG}
   ```

1. **Edit the resource file**

   Locate the `resources/applications/acme-payment.yml` file and update the following placeholders:

   - **`<acr-name>`**: Update to the name of your Azure Container Registry, should be the value of `${ACR_NAME}`.
   - **`<payment-service-app-image-tag>`**: Update to the tag of your application image, should be the value of `${PAYMENT_SERVICE_APP_IMAGE_TAG}`.

   ```yaml
   image: <acr-name>.azurecr.io/acme-payment:<payment-service-app-image-tag>
   ```

1. **Deploy the Application**

   To deploy the application, use the following command:
   ```sh
   kubectl apply -f resources/applications/acme-payment.yml
   ```

   This command will create the following Kubernetes resources:

   1. **ConfigMap**: `payment-config`
      - Stores configuration data for the payment service.
      - Contains environment variables such as `EUREKA_CLIENT_ENABLED`.

   2. **Deployment**: `payment`
      - Manages the deployment of the payment application.
      - Retrieves environment variables from the `config-server-config` and `eureka-server-config` ConfigMaps to connect to Spring Cloud components.
      - Uses the `payment-config` ConfigMap for additional configuration. This ConfigMap can store the environment variables that you want to send to the application. Note that once the ConfigMap is updated, the deployment needs to be restarted to take effect.
      - Configures probes for liveness and readiness to ensure the application is running correctly.
      - Specifies resource limits and requests for CPU, memory, and ephemeral storage.

   3. **Service**: `payment-service`
      - Exposes the payment application within the Kubernetes cluster.
      - Uses a `ClusterIP` type to provide a stable internal IP address.
      - Routes traffic on port 80 to the application's container port 8080.

1. **Verify the deployment**

   Wait for the pod to start running. You can check the status with:
   ```bash
   kubectl get pods
   ```

   You should see output similar to:
   ```
   NAME                        READY   STATUS    RESTARTS   AGE
   payment-7656c865bb-4db2p    1/1     Running   0          3m
   ```

   **Tip**: If the pod is not running, check for errors using:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

1. **View the application in Spring Boot Admin**

   Open the hostname for your Spring Boot Admin, you should see the application.

## Next Steps

- Follow [09-03-deploy-spring-boot-application-connect-postgresql](./09-03-deploy-spring-boot-application-connect-postgresql.md) to deploy the Acme Catalog application and connect it to PostgreSQL.