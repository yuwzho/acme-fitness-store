---
Onwer: Zhe
Prerequisites:
- Existing AKS
- Existing Eureka Server
Output:
- Provision OSS Spring Boot Admin
- Register the Spring Boot Admin to Eureka
---

## Install Pack CLI

To install Pack CLI, refer to the official [Pack CLI installation guide](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/).

## Set Up Spring Boot Admin Server

To create a Spring Boot Admin server, follow the [Getting Started documentation](https://docs.spring-boot-admin.com/3.0.0/getting-started.html). For registering client applications, you may use Spring Cloud Discovery instead of the Spring Boot Admin Client. This approach does not require modifications to your applications' configurations.

## Build, Package, and Publish the Spring Boot Admin Server Image to ACR

1. **Set your container registry**:
   ```bash
   export CONTAINER_REGISTRY=<input-here>   # e.g., myacr.azurecr.io/acme-fitness-store or myname/acme-fitness-store
   ```

1. **Build the container image**:
   ```bash
   pack build ${CONTAINER_REGISTRY}/spring-boot-admin --path . \
    --builder paketobuildpacks/builder-jammy-base \
    -e BP_JVM_VERSION=17
   ```

1. **Push the image to the container registry**:
   ```bash
   docker push ${CONTAINER_REGISTRY}/spring-boot-admin
   ```
## Deploy the Spring Cloud Gateway Image in AKS

. **Get AKS Access Credential**

   ```bash
   az aks get-credentials --resource-group $AKS_RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --subscription $AKS_SUBSCRIPTION_ID --admin
   ```

1. **Create the Kubernetes Resource File**

   Save below content to springbootadmin.yaml:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: spring-boot-admin
   spec:
     progressDeadlineSeconds: 600
     replicas: 1
     revisionHistoryLimit: 10
     selector:
       matchLabels:
         app: spring-boot-admin
     strategy:
       rollingUpdate:
         maxSurge: 55%
         maxUnavailable: 25%
       type: RollingUpdate
     template:
       metadata:
         annotations:
           cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
         labels:
           app: spring-boot-admin
       spec:
         containers:
         - image: acmeacr.azurecr.io/spring-boot-admin:latest
           imagePullPolicy: Always
           livenessProbe:
             failureThreshold: 3
             initialDelaySeconds: 300
             periodSeconds: 10
             successThreshold: 1
             tcpSocket:
               port: 8080
             timeoutSeconds: 3
           name: spring-boot-admin
           ports:
           - containerPort: 8080
             name: app-port
             protocol: TCP
           readinessProbe:
             failureThreshold: 3
             periodSeconds: 5
             successThreshold: 1
             tcpSocket:
               port: 8080
             timeoutSeconds: 3
           resources:
             limits:
               cpu: "1"
               ephemeral-storage: 5000Mi
               memory: 1Gi
             requests:
               cpu: "1"
               ephemeral-storage: 5000Mi
               memory: 1Gi
           securityContext:
             allowPrivilegeEscalation: false
             capabilities:
               add:
               - NET_BIND_SERVICE
               drop:
               - NET_RAW
             privileged: false
             seccompProfile:
               type: RuntimeDefault
           terminationMessagePath: /dev/termination-log
           terminationMessagePolicy: File
         dnsPolicy: ClusterFirst
         restartPolicy: Always
         schedulerName: default-scheduler
         terminationGracePeriodSeconds: 30
   ```

1. **Apply the Kubernetes Configuration**

   Use `kubectl` to apply the configuration and create the eureka server:

   ```bash
   kubectl apply -f springbootadmin.yaml
   ```

   It creates Spring Boot Admin deployment.

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
