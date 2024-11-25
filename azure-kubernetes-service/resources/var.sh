# Resource group and service names
LOCATION="eastus2"
SUBSCRIPTION="<azure-subscription-id>"
RESOURCE_GROUP="<resource-group>"
ACR_NAME="<container-registry-name-character-only>"
AKS_NAME="${RESOURCE_GROUP}-k8s"
KEYVAULT_NAME="${RESOURCE_GROUP}-kv"
WORKSPACE_NAME="${RESOURCE_GROUP}-workspace"

# Supporting services
POSTGRESQL_NAME="${RESOURCE_GROUP}-postgres"
REDIS_NAME="${RESOURCE_GROUP}-redis"

# Docker image tags for Spring Cloud components
EUREKA_IMAGE_TAG="acrbuild-eureka-0.0.1-SNAPSHOT"
CONFIGSERVER_IMAGE_TAG="acrbuild-config-server-0.0.1-SNAPSHOT"
SPRING_BOOT_ADMIN_IMAGE_TAG="acrbuild-spring-boot-admin-0.0.1-SNAPSHOT"
GATEWAY_IMAGE_TAG="acrbuild-spring-cloud-gateway-0.0.1-SNAPSHOT"

# Update docker image tag
IMAGE_VERSION="0.0.1-SNAPSHOT"

# Docker image tags for applications
CATALOG_SERVICE_APP_IMAGE_TAG="buildpack-catalog-${IMAGE_VERSION}"
PAYMENT_SERVICE_APP_IMAGE_TAG="buildpack-payment-${IMAGE_VERSION}"
ORDER_SERVICE_APP_IMAGE_TAG="buildpack-order-${IMAGE_VERSION}"
CART_SERVICE_APP_IMAGE_TAG="buildpack-cart-${IMAGE_VERSION}"
FRONTEND_APP_IMAGE_TAG="buildpack-frontend-${IMAGE_VERSION}"
