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
