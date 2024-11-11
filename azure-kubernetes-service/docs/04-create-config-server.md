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

## Use the Config Server

1. **Prepare ConfigMap**

   To use the Config Server for your applications, apply the configmap in the directory `resources/config-server` and mount the configmap to the application:

   ```bash
   kubectl apply -f configserver-config.yaml
   ```

2. **Configure the Application**

   Make sure the application has the dependency `spring-cloud-starter-config`. And Configure `SPRING_APPLICATION_NAME` in the configmap of the application and the value of it should equal to the config file name in the git repository. 

3. **Verify the Application**
   
   If the application is connected to the Config Server successfully, you can see logs in the application like following:

   ```
   2024-11-11 06:24:53.185  INFO 1 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Fetching config from server at : http://config-server-default.default.svc.cluster.local:8888
   2024-11-11 06:24:53.679  INFO 1 --- [           main] c.c.c.ConfigServicePropertySourceLocator : Located environment: name=catalog, profiles=[default], label=null, version=d145f5aa2a5e856d0402a08d1725cec602bb89b0, state=null
   2024-11-11 06:24:53.680  INFO 1 --- [           main] b.c.PropertySourceBootstrapConfiguration : Located property source: [BootstrapPropertySource {name='bootstrapProperties-configClient'}, BootstrapPropertySource {name='bootstrapProperties-https://github.com/Azure-Samples/acme-fitness-store-config/Config resource 'file [/tmp/config-repo-203394081967964840/catalog.yml' via location '' (document #0)'}]
   ```