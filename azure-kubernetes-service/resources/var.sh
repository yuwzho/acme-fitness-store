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
EUREKA_IMAGE_TAG="acrbuild-eureka"
CONFIGSERVER_IMAGE_TAG="acrbuild-config-server"
SPRING_BOOT_ADMIN_IMAGE_TAG="acrbuild-spring-boot-admin"
GATEWAY_IMAGE_TAG="acrbuild-spring-cloud-gateway"

# Docker image tags for applications
CATALOG_SERVICE_APP_IMAGE_TAG="buildpack-catalog"
PAYMENT_SERVICE_APP_IMAGE_TAG="buildpack-payment"
ORDER_SERVICE_APP_IMAGE_TAG="buildpack-order"
CART_SERVICE_APP_IMAGE_TAG="buildpack-cart"
FRONTEND_APP_IMAGE_TAG="buildpack-frontend"
