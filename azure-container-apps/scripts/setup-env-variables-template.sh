# Resource group and environment names
SUBSCRIPTION='subscription-id'                 # replace it with your subscription-id
PREFIX='unique-prefix'                         # unique prefix for all resources(not use special characters)
RESOURCE_GROUP=${PREFIX}-rg
ENVIRONMENT=${PREFIX}-env
LOCATION='eastus2'

#services name
CATALOG_SERVICE_APP='acme-catalog'
PAYMENT_SERVICE_APP='acme-payment'
ORDER_SERVICE_APP='acme-order'
CART_SERVICE_APP='acme-cart'
FRONTEND_APP='frontend'

# Java components
CONFIG_COMPONENT_NAME=${PREFIX}config
CONFIG_SERVER_GIT_URI="https://github.com/Azure-Samples/acme-fitness-store-config"
EUREKA_COMPONENT_NAME=${PREFIX}eureka
GATEWAY_COMPONENT_NAME=${PREFIX}gateway
ROUTE_PATH='routes.yml'
ADMIN_COMPONENT_NAME=${PREFIX}admin

# database and cache
AZURE_CACHE_NAME=${PREFIX}-redis
POSTGRES_SERVER_NAME=${PREFIX}-postgre
CATALOG_SERVICE_DB='catalogdb'
CART_SERVICE_CACHE_CONNECTION=${PREFIX}cartconnection
CATALOG_SERVICE_PSQL_CONNECTION=${PREFIX}catalogconnection

# ACR and image tags
ACR_NAME=${PREFIX}acr
ACR_LOGIN_SERVER=${ACR_NAME}.azurecr.io
APP_IMAGE_TAG="latest"
