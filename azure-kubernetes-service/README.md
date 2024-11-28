# Azure Kubernetes Service Documentation

This folder contains documentation for setting up and deploying various components on Azure Kubernetes Service (AKS) for the Acme Fitness Store project.

## Table of Contents

1. [01-create-kubernetes-service.md](./docs/01-create-kubernetes-service.md)
   - Step-by-step guide to create an Azure Kubernetes Service (AKS) cluster, integrate it with Azure Container Registry (ACR), and set up Azure Key Vault and Nginx ingress with a CA certificate.

2. [02-create-eureka-server.md](./docs/02-create-eureka-server.md)
   - Instructions to create and deploy a Eureka Server on AKS for service discovery.

3. [03-create-config-server.md](./docs/03-create-config-server.md)
   - Guide to create and deploy a Spring Cloud Config Server on AKS for centralized configuration management.

4. [04-create-spring-boot-admin.md](./docs/04-create-spring-boot-admin.md)
   - Steps to create and deploy a Spring Boot Admin server on AKS for managing and monitoring Spring Boot applications.

5. [05-create-application-gateway.md](./docs/05-create-application-gateway.md)
   - Instructions to create and deploy a Spring Cloud Gateway on AKS for API Gateway functionality.

6. [06-create-application-supporting-service.md](./docs/06-create-application-supporting-service.md)
   - Guide to set up supporting services like PostgreSQL and Redis Cache for your applications on AKS.

7. [08-containerize-application.md](./docs/08-containerize-application.md)
   - Steps to build and push application images to Azure Container Registry.

8. [09-02-deploy-application-connect-spring-cloud-component.md](./docs/09-02-deploy-application-connect-spring-cloud-component.md)
   - Instructions to deploy the Acme Payment application on AKS and connect it to Spring Cloud components.

9. [09-03-deploy-spring-boot-application-connect-postgresql.md](./docs/09-03-deploy-spring-boot-application-connect-postgresql.md)
   - Guide to deploy the Acme Catalog application on AKS and connect it to a PostgreSQL database.

10. [09-04-deploy-dotnet-application-connect-postgresql.md](./docs/09-04-deploy-dotnet-application-connect-postgresql.md)
    - Steps to deploy the Acme Order application on AKS and connect it to a PostgreSQL database.

11. [09-05-deploy-python-application-connect-with-redis.md](./docs/09-05-deploy-python-application-connect-with-redis.md)
    - Instructions to deploy the Acme Cart application on AKS and connect it to a Redis cache.

12. [10-get-log-and-metrics.md](./docs/10-get-log-and-metrics.md)
    - Guide to view logs and metrics for your AKS cluster to monitor containerized applications effectively.
