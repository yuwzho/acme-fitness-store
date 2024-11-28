# Update Application Code

## Introduction

In this guide, we will update the application code to include the Spring Cloud config client dependency. This will allow your application to connect to the Config Server and retrieve the necessary configuration.

## Steps

1. **Update Spring Cloud config client dependency for acme-catalog**

   Locate the `../apps/acme-catalog/build.gradle` file and add the Spring Cloud config client dependency. This dependency will consume the environment and let your application connect to the Config Server to retrieve the configuration.

   ```diff
   --- a/apps/acme-catalog/build.gradle
   +++ b/apps/acme-catalog/build.gradle
   @@ -33,6 +33,7 @@ dependencies {
         implementation 'org.flywaydb:flyway-core'

         implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
   +     implementation 'org.springframework.cloud:spring-cloud-starter-config'

         implementation 'com.azure.spring:spring-cloud-azure-starter-keyvault-secrets'
   ```

2. **Update Spring Cloud config client dependency for acme-payment**

   Locate the `../apps/acme-payment/build.gradle` file and add the Spring Cloud config client dependency. This dependency will consume the environment and let your application connect to the Config Server to retrieve the configuration.

   ```diff
   --- a/apps/acme-payment/build.gradle
   +++ b/apps/acme-payment/build.gradle
   @@ -29,6 +29,7 @@ dependencies {
         implementation 'org.springframework.boot:spring-boot-starter-webflux'

         implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
   +     implementation 'org.springframework.cloud:spring-cloud-starter-config'

         runtimeOnly 'io.micrometer:micrometer-registry-prometheus'
   ```

## Next Steps

- Verify that the dependencies have been added correctly by building the projects.
- Deploy the updated applications to your environment.
- Test the applications to ensure they can retrieve configurations from the Config Server.
