## Introduction

In this guide, you will learn how to create and deploy a Spring Cloud Config Server on Azure Kubernetes Service (AKS). The Config Server provides a central place to manage external properties for applications across all environments. For more information on Spring Cloud Config Server, refer to the [official documentation](https://cloud.spring.io/spring-cloud-config/reference/html/).


## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Maven
- Azure CLI
- Docker

## Outputs

By the end of this guide, you will have a running Spring Cloud Config Server on your AKS cluster.

## Steps

### Prepare the Spring Cloud Config Server Image

1. **Setup variables**
   
   Set up the variables used to deploy the Config Server
   ```bash
   source resources/var.sh
   echo "RESOURCE_GROUP=${RESOURCE_GROUP}"
   echo "AKS_NAME=${AKS_NAME}"
   echo "ACR_NAME=${ACR_NAME}"
   echo "CONFIGSERVER_IMAGE_TAG=${CONFIGSERVER_IMAGE_TAG}"
   ```

1. **Clone the Repository**

   The code is under `resources/config-server`. Enter the directory, there is also a `Dockerfile`.

1. **Build and Push the Docker Image**

    ```azurecli
    cd azure-kubernetes-service/resources/config-server
    az acr build --image ${CONFIGSERVER_IMAGE_TAG} --registry ${ACR_NAME} --file Dockerfile . --resource-group ${RESOURCE_GROUP}
    ```

### Deploy the Spring Cloud Config Server

1. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --admin
   ```

1. **Edit the Kubernetes Resource File**

   Locate the `configserver.yaml` file in the `resources/config-server` directory. Edit the following code snippet.

   - **`<config-server-image-tag>`**: Update to the value of `${CONFIGSERVER_IMAGE_TAG}`
   - **`<acr-name>`**: Update to the value of `${ACR_NAME}`

   ```yaml
      containers:
      - name: config-server
        image: "<acr-name>.azurecr.io/config-server:<config-server-image-tag>"
   ```

   This YAML file is used to configure the deployment of the Config Server.
   It includes the environment variables injected into the Config Server. For more details about the configuration, see https://docs.spring.io/spring-cloud-config/docs/current/reference/html/#_git_backend.

   Environment Variables:
   - `SPRING_CLOUD_CONFIG_SERVER_GIT_URI`: The URI of the Git repository where the configuration files are stored.
   - `SPRING_CLOUD_CONFIG_SERVER_GIT_SEARCH_PATHS`: The search paths within the Git repository for configuration files.
   - `SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME`: The username for accessing the Git repository.
   - `SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD`: The password for accessing the Git repository.
   - `SPRING_CLOUD_CONFIG_SERVER_GIT_SKIP_SSL_VALIDATION`: Whether to skip SSL validation for the Git repository.

1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the Config Server:

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

### Use the Config Server

1. **Prepare ConfigMap**

   To use the Config Server for your applications, apply the configmap in the directory `resources/config-server` and mount the configmap to the application:

   ```bash
   kubectl apply -f configserver-config.yaml
   ```

2. **Configure the Application**

   Make sure the application has the dependency `spring-cloud-starter-config`. And configure `SPRING_APPLICATION_NAME` in the configmap of the application and the value of it should equal to the config file name in the git repository.

3. **Verify the Application**
   
   If the application is connected to the Config Server successfully, you can see logs in the application like the following:

   ```
   2024-11-11 06:24:53.185  INFO 1 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Fetching config from server at : http://config-server-default.default.svc.cluster.local:8888
   2024-11-11 06:24:53.679  INFO 1 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Located environment: name=catalog, profiles=[default], label=null, version=d145f5aa2a5e856d0402a08d1725cec602bb89b0, state=null
   2024-11-11 06:24:53.680  INFO 1 --- [           main] b.c.PropertySourceBootstrapConfiguration : Located property source: [BootstrapPropertySource {name='bootstrapProperties-configClient'}, BootstrapPropertySource {name='bootstrapProperties-https://github.com/Azure-Samples/acme-fitness-store-config/Config resource 'file [/tmp/config-repo-203394081967964840/catalog.yml' via location '' (document #0)'}]
   ```

## Next Steps

- Follow [04-create-spring-boot-admin](./04-create-spring-boot-admin.md) to create and deploy a Spring Boot Admin server on Azure Kubernetes Service.