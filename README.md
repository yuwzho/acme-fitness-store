---
page_type: sample
languages:
- java
products:
- Azure Spring Apps
- Azure Database for PostgreSQL
- Azure Cache for Redis
- Azure Active Directory
description: "Deploy Microservice Apps to Azure"
urlFragment: "acme-fitness-store"
---
# ACME Fitness Store

ACME Fitness store is a fictional online retailer selling sporting goods. This
repo contains the source code for the ACME Fitness store application.  

## High Level Architecture
![An image showing the services involved in the ACME Fitness Store. It depicts the applications and their dependencies](./azure-spring-apps-enterprise/media/architecture.jpg)

This application is composed of several services:

* 3 Java Spring Boot applications:
  * A catalog service for fetching available products. 
  * A payment service for processing and approving payments for users' orders
  * An identity service for referencing the authenticated user

* 1 Python application:
  * A cart service for managing a users' items that have been selected for purchase

* 1 ASP.NET Core applications:
  * An order service for placing orders to buy products that are in the users' carts

* 1 NodeJS and static HTML Application
  * A frontend shopping application

The sample can be deployed to Azure Spring Apps Enterprise or Tanzu Application
Platform. 

## Repo organization 

This repo contains the following folders:


| Directory                                                        | Purpose |
| ---------------------------------------------------------------- | ------------- |
| [apps](./apps)                                                   | source code for the services  |
| [azure-spring-apps-enterprise](./azure-spring-apps-enterprise)   | documentaion and scripts for deploying to Azure Spring Apps Enterprise |
| [tanzu-application-platform](./tanzu-application-platform)       | documentation and scripts for deploying to Tanzu Application Platform|

# Deploy Spring Boot Apps to Azure Spring Apps Enterprise

Azure Spring Apps Enterprise enables you to easily run Spring Boot and 
polyglot applications on Azure. Follow the instructions in 
[azure-spring-apps-enterprise/README.md](./azure-spring-apps-enterprise/README.md) 
to deploy the ACME Fitness store application to Azure Spring Apps Enterprise.

The 


[acme-fitness-example](./azure-spring-apps-enterprise/README.md)

# Deploy Apps to Tanzu Application Platform (TAP)

Tanzu Application Platform enables you to easily build & run polyglot applications on CNCF Compliant Kubernetes clusters.

[acme-fitness-example](./tanzu-application-platform/README.md)


