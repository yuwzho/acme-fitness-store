## Introduction

In this guide, we will walk you through the process of deploying the Acme Frontend application to an Azure Kubernetes Service (AKS) and connecting it to deployed Spring Cloud components.

## Prerequisites

Before you begin, ensure you have the following:

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Follow [07-containerize-application](./08-containerize-application.md) to build the image and push it to the Azure Container Registry.
- Follow [04-create-spring-cloud-gateway](./05-create-application-gateway.md) to create the Spring Cloud Gateway for routing.

## Outputs

After completing this guide, you will have:

- Deployed the Acme Frontend application to your Kubernetes cluster.
- Exposed the application within the cluster and made it discoverable by Spring Cloud Gateway.

## Steps

1. **Set up the variables**

   Set up the variables used to deploy the frontend app:
   ```bash
   source resources/var.sh
   az account set -s ${SUBSCRIPTION}

   echo ACR_NAME=${ACR_NAME}
   echo FRONTEND_APP_IMAGE_TAG=${FRONTEND_APP_IMAGE_TAG}
   ```

1. **Edit the resource file**

   Locate the `resources/applications/frontend.yml` file and update the following placeholders:

   - **`<acr-name>`**: Update to the name of your Azure Container Registry, should be the value of `${ACR_NAME}`.
   - **`<frontend-app-image-tag>`**: Update to the tag of your application image, should be the value of `${FRONTEND_APP_IMAGE_TAG}`.

1. **Deploy the Application**

   To deploy the application, use the following command:
   ```sh
   kubectl apply -f resources/applications/frontend.yml
   ```

   This command will create the following Kubernetes resources:

   1. **Deployment**: `frontend`
      - Manages the deployment of the frontend application.
      - Configures probes for liveness and readiness to ensure the application is running correctly.
      - Specifies resource limits and requests for CPU, memory, and ephemeral storage.

   2. **Service**: `frontend`
      - Exposes the frontend application within the Kubernetes cluster.
      - Uses a `ClusterIP` type to provide a stable internal IP address.
      - Routes traffic on port 80 to the application's container port 8080.
      - This service can be discovered by Spring Cloud Gateway.

1. **Verify the deployment**

   Wait for the pod to start running. You can check the status with:
   ```bash
   kubectl get pods
   ```

   You should see output similar to:
   ```
   NAME                        READY   STATUS    RESTARTS   AGE
   frontend-7656c865bb-4db2p    1/1     Running   0          3m
   ```

   **Tip**: If the pod is not running, check for errors using:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

1. **View the application through Spring Cloud Gateway**

   Open the hostname for your Spring Cloud Gateway, you should see the application.

## Next Steps

- Follow [09-02-deploy-application-connect-spring-cloud-component](./09-02-deploy-application-connect-spring-cloud-component.md) to deploy the Acme Payment application and connect it to Spring Cloud components.