#!/bin/bash

set -euo pipefail

readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
readonly APPS_ROOT="${PROJECT_ROOT}/apps"

readonly REDIS_NAME="fitness-cache-demo"
readonly ORDER_SERVICE_POSTGRES_CONNECTION="order_service_db"
readonly CART_SERVICE_REDIS_CONNECTION="cart_service_cache"
readonly CATALOG_SERVICE_DB_CONNECTION="catalog_service_db"
readonly ACMEFIT_CATALOG_DB_NAME="acmefit_catalog"
readonly ACMEFIT_ORDER_DB_NAME="acmefit_order"
readonly ACMEFIT_POSTGRES_DB_PASSWORD="Acm3F!tness"
readonly ACMEFIT_POSTGRES_DB_USER=dbadmin
readonly ACMEFIT_POSTGRES_SERVER="acmefitnessdb-demo"
readonly ORDER_DB_NAME="orders"
readonly CART_SERVICE="cart-service"
readonly IDENTITY_SERVICE="identity-service"
readonly ORDER_SERVICE="order-service"
readonly PAYMENT_SERVICE="payment-service"
readonly CATALOG_SERVICE="catalog-service"
readonly FRONTEND_APP="frontend"
readonly CUSTOM_BUILDER="no-bindings-builder"
readonly CURRENT_USER=$(az account show --query user.name -o tsv)
readonly CURRENT_USER_OBJECTID=$(az ad user show --id $CURRENT_USER --query objectId -o tsv)
readonly CONFIG_REPO=https://github.com/felipmiguel/acme-fitness-store-config
readonly CATALOG_APP_PSQL_USER=catalogapp
readonly JDBC_CONNECTION_STRING_CATALOG="jdbc:postgresql://${ACMEFIT_POSTGRES_SERVER}.postgres.database.azure.com:5432/${ACMEFIT_CATALOG_DB_NAME}?sslmode=require&user=${CATALOG_APP_PSQL_USER}@${ACMEFIT_POSTGRES_SERVER}&authenticationPluginClassName=com.azure.jdbc.msi.extension.postgresql.AzurePostgresqlMSIAuthenticationPlugin"

RESOURCE_GROUP='rg-acme-fitness'
SPRING_CLOUD_INSTANCE='asc-acme-fitness'
REGION='eastus'

function create_spring_cloud() {
  az group create --name ${RESOURCE_GROUP} \
    --location ${REGION}

  az provider register --namespace Microsoft.SaaS
  az term accept --publisher vmware-inc --product azure-spring-cloud-vmware-tanzu-2 --plan tanzu-asc-ent-mtr

  az spring-cloud create --name ${SPRING_CLOUD_INSTANCE} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${REGION} \
    --sku Enterprise \
    --enable-application-configuration-service \
    --enable-service-registry \
    --enable-gateway \
    --enable-api-portal

}

function configure_defaults() {
  echo "Configure azure defaults resource group: $RESOURCE_GROUP and spring-cloud $SPRING_CLOUD_INSTANCE"
  az configure --defaults group=$RESOURCE_GROUP spring-cloud=$SPRING_CLOUD_INSTANCE location=${REGION}
}

function create_dependencies() {
  echo "Creating Azure Cache for Redis Instance $REDIS_NAME in location ${REGION}"
  az redis create --location $REGION --name $REDIS_NAME --resource-group $RESOURCE_GROUP --sku Basic --vm-size c0

  echo "Creating Azure Database for Postgres $ACMEFIT_POSTGRES_SERVER"

  az postgres server create --admin-user ${ACMEFIT_POSTGRES_DB_USER} \
    --admin-password $ACMEFIT_POSTGRES_DB_PASSWORD \
    --name $ACMEFIT_POSTGRES_SERVER \
    --resource-group $RESOURCE_GROUP \
    --sku-name GP_Gen5_2 \
    --version 11 \
    --storage-size 5120

  echo "Creating current logged in user as postgres AD Admin"
  az postgres server ad-admin create -s $ACMEFIT_POSTGRES_SERVER \
    -g $RESOURCE_GROUP \
    -u $CURRENT_USER \
    -i $CURRENT_USER_OBJECTID

  echo "Creating Postgres Database $ACMEFIT_CATALOG_DB_NAME"
  az postgres db create \
    --name $ACMEFIT_CATALOG_DB_NAME \
    --server-name $ACMEFIT_POSTGRES_SERVER

  echo "Creating Postgres Database $ACMEFIT_ORDER_DB_NAME"
  az postgres db create \
    --name $ACMEFIT_ORDER_DB_NAME \
    --server-name $ACMEFIT_POSTGRES_SERVER
}

function create_builder() {
  echo "Creating a custom builder with name $CUSTOM_BUILDER and configuration $PROJECT_ROOT/azure/builder.json"
  az spring-cloud build-service builder create -n $CUSTOM_BUILDER --builder-file "$PROJECT_ROOT/azure/builder.json"
}

function configure_sso() {
  az ad app create --display-name acme-fitness >ad.json
  export APPLICATION_ID=$(cat ad.json | jq -r '.appId')

  az ad app credential reset --id ${APPLICATION_ID} --append >sso.json
  az ad sp create --id ${APPLICATION_ID}

  source ./setup-sso-variables-ad.sh
}

function configure_gateway() {
  az spring-cloud gateway update --assign-endpoint true
  local gateway_url=$(az spring-cloud gateway show | jq -r '.properties.url')

  source ./setup-sso-variables-ad.sh
  echo "Configuring Spring Cloud Gateway"
  az spring-cloud gateway update \
    --api-description "ACME Fitness API" \
    --api-title "ACME Fitness" \
    --api-version "v.01" \
    --server-url "https://$gateway_url" \
    --allowed-origins "*" \
    --client-id ${CLIENT_ID} \
    --client-secret ${CLIENT_SECRET} \
    --scope "openid,profile" \
    --issuer-uri ${ISSUER_URI}
}

function configure_acs() {
  echo "Configuring Application Configuration Service to use repo: ${CONFIG_REPO}"
  az spring-cloud application-configuration-service git repo add --name acme-config --label main --patterns "default,catalog,identity,payment" --uri "${CONFIG_REPO}" --search-paths config
}

function create_cart_service() {
  echo "Creating cart-service app"
  az spring-cloud app create --name $CART_SERVICE
  az spring-cloud gateway route-config create --name $CART_SERVICE --app-name $CART_SERVICE --routes-file "$PROJECT_ROOT/azure/routes/cart-service.json"

  az spring-cloud connection create redis \
    --service $SPRING_CLOUD_INSTANCE \
    --deployment default \
    --resource-group $RESOURCE_GROUP \
    --target-resource-group $RESOURCE_GROUP \
    --server $REDIS_NAME \
    --database 0 \
    --app $CART_SERVICE \
    --client-type java \
    --connection $CART_SERVICE_REDIS_CONNECTION
}

function create_identity_service() {
  echo "Creating identity service"
  az spring-cloud app create --name $IDENTITY_SERVICE
  az spring-cloud application-configuration-service bind --app $IDENTITY_SERVICE
  az spring-cloud gateway route-config create --name $IDENTITY_SERVICE --app-name $IDENTITY_SERVICE --routes-file "$PROJECT_ROOT/azure/routes/identity-service.json"
}

function create_order_service() {
  echo "Creating order service"
  az spring-cloud app create --name $ORDER_SERVICE
  az spring-cloud gateway route-config create --name $ORDER_SERVICE --app-name $ORDER_SERVICE --routes-file "$PROJECT_ROOT/azure/routes/order-service.json"

  az spring-cloud connection create postgres \
    --resource-group $RESOURCE_GROUP \
    --service $SPRING_CLOUD_INSTANCE \
    --connection $ORDER_SERVICE_POSTGRES_CONNECTION \
    --app $ORDER_SERVICE \
    --deployment default \
    --tg $RESOURCE_GROUP \
    --server $ACMEFIT_POSTGRES_SERVER \
    --database $ACMEFIT_ORDER_DB_NAME \
    --secret name=${ACMEFIT_POSTGRES_DB_USER} secret=${ACMEFIT_POSTGRES_DB_PASSWORD} \
    --client-type dotnet
}

function create_catalog_service() {
  echo "Creating catalog service with managed identity"
  az spring-cloud app create \
    --name $CATALOG_SERVICE \
    --system-assigned true
  az spring-cloud application-configuration-service bind --app $CATALOG_SERVICE
  az spring-cloud service-registry bind --app $CATALOG_SERVICE
  az spring-cloud gateway route-config create --name $CATALOG_SERVICE --app-name $CATALOG_SERVICE --routes-file "$PROJECT_ROOT/azure/routes/catalog-service.json"

  # az spring-cloud connection create postgres \
  #   --resource-group $RESOURCE_GROUP \
  #   --service $SPRING_CLOUD_INSTANCE \
  #   --connection $CATALOG_SERVICE_DB_CONNECTION \
  #   --app $CATALOG_SERVICE \
  #   --deployment default \
  #   --tg $RESOURCE_GROUP \
  #   --server $ACMEFIT_POSTGRES_SERVER \
  #   --database $ACMEFIT_CATALOG_DB_NAME \
  #   --secret name=${ACMEFIT_POSTGRES_DB_USER} secret=${ACMEFIT_POSTGRES_DB_PASSWORD} \
  #   --client-type springboot
  # az spring-cloud connection create
}

function create_payment_service() {
  echo "Creating payment service"
  az spring-cloud app create --name $PAYMENT_SERVICE
  az spring-cloud application-configuration-service bind --app $PAYMENT_SERVICE
  az spring-cloud service-registry bind --app $PAYMENT_SERVICE
}

function create_frontend_app() {
  echo "Creating frontend"
  az spring-cloud app create --name $FRONTEND_APP
  az spring-cloud gateway route-config create --name $FRONTEND_APP --app-name $FRONTEND_APP --routes-file "$PROJECT_ROOT/azure/routes/frontend.json"
}

function deploy_cart_service() {
  echo "Deploying cart-service application"
  local redis_conn_str=$(az spring-cloud connection show -g $RESOURCE_GROUP \
    --service $SPRING_CLOUD_INSTANCE \
    --deployment default \
    --app $CART_SERVICE \
    --connection $CART_SERVICE_REDIS_CONNECTION | jq -r '.configurations[0].value')
  local gateway_url=$(az spring-cloud gateway show | jq -r '.properties.url')
  local app_insights_key=$(az spring-cloud build-service builder buildpack-binding show -n default | jq -r '.properties.launchProperties.properties."connection-string"')

  az spring-cloud app deploy --name $CART_SERVICE \
    --builder $CUSTOM_BUILDER \
    --env "CART_PORT=8080" "REDIS_CONNECTIONSTRING=$redis_conn_str" "AUTH_URL=https://${gateway_url}" "INSTRUMENTATION_KEY=$app_insights_key" \
    --source-path "$APPS_ROOT/acme-cart"
}

function deploy_identity_service() {
  source ./setup-sso-variables-ad.sh
  echo "Deploying identity-service application"
  az spring-cloud app deploy --name $IDENTITY_SERVICE \
    --env "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI=${JWK_SET_URI}" \
    --config-file-pattern identity \
    --source-path "$APPS_ROOT/acme-identity"
}

function deploy_order_service() {
  echo "Deploying user-service application"
  local gateway_url=$(az spring-cloud gateway show | jq -r '.properties.url')
  local postgres_connection_url=$(az spring-cloud connection show -g $RESOURCE_GROUP \
    --service $SPRING_CLOUD_INSTANCE \
    --deployment default \
    --connection $ORDER_SERVICE_POSTGRES_CONNECTION \
    --app $ORDER_SERVICE | jq '.configurations[0].value' -r)
  local app_insights_key=$(az spring-cloud build-service builder buildpack-binding show -n default | jq -r '.properties.launchProperties.properties."connection-string"')

  echo $postgres_connection_url
  az spring-cloud app deploy --name $ORDER_SERVICE \
    --builder $CUSTOM_BUILDER \
    --env "DatabaseProvider=Postgres" "ConnectionStrings__OrderContext=$postgres_connection_url" "AcmeServiceSettings__AuthUrl=https://${gateway_url}" "ApplicationInsights__ConnectionString=$app_insights_key" \
    --source-path "$APPS_ROOT/acme-order"
}

function deploy_catalog_service() {
  echo "Deploying catalog-service application"

  az spring-cloud app deploy --name $CATALOG_SERVICE \
    --config-file-pattern catalog \
    --env "SPRING_DATASOURCE_URL=${JDBC_CONNECTION_STRING_CATALOG}" \
    --source-path "$APPS_ROOT/acme-catalog"
}

function deploy_payment_service() {
  echo "Deploying payment-service application"

  az spring-cloud app deploy --name $PAYMENT_SERVICE \
    --config-file-pattern payment \
    --source-path "$APPS_ROOT/acme-payment"
}

function deploy_frontend_app() {
  echo "Deploying frontend application"
  local app_insights_key=$(az spring-cloud build-service builder buildpack-binding show -n default | jq -r '.properties.launchProperties.properties."connection-string"')

  rm -rf "$APPS_ROOT/acme-shopping/node_modules"
  az spring-cloud app deploy --name $FRONTEND_APP \
    --builder $CUSTOM_BUILDER \
    --env "APPLICATIONINSIGHTS_CONNECTION_STRING=$app_insights_key" \
    --source-path "$APPS_ROOT/acme-shopping"
}

function create_databaseuser() {
  echo "Creating database user"
  # IMPORTANT PSQL REQUIRES THE APPLICATION ID OF THE MANAGED IDENTITY, NOT THE OBJECT ID.
  # First step: retrieve the object id of the application managed identity
  managedidentity_oid=$(az spring-cloud app show --name $CATALOG_SERVICE --query identity.principalId -o tsv)
  # Second step: retrieve the application id using the object id
  managedidentity_appid=$(az ad sp show --id ${managedidentity_oid} --query appId -o tsv)

  CURRENT_IP=$(curl -s http://whatismyip.akamai.com)
  # allow current agent to access the database
  az postgres server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $ACMEFIT_POSTGRES_SERVER \
    --name allow-current-agent \
    --start-ip-address $CURRENT_IP \
    --end-ip-address $CURRENT_IP


  # Prepare the script using the applicationid
  create_user_sql="SET aad_validate_oids_in_tenant = off;

REVOKE ALL PRIVILEGES ON DATABASE \"acmefit_catalog\" FROM \"catalogapp\";

DROP USER IF EXISTS \"catalogapp\";

CREATE ROLE \"catalogapp\" WITH LOGIN PASSWORD '${managedidentity_appid}' IN ROLE azure_ad_user;

GRANT ALL PRIVILEGES ON DATABASE \"acmefit_catalog\" TO \"catalogapp\";"

  # the script should be execute by the Azure AD admin.
  # current user is Azure AD Admin

  # as password is too long it cannot be passed as parameter to PSQL, so we use and environment variable
  export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)
  echo $create_user_sql > create_user.sql
  psql "host=${ACMEFIT_POSTGRES_SERVER}.postgres.database.azure.com port=5432 user=${CURRENT_USER}@${ACMEFIT_POSTGRES_SERVER} dbname=postgres sslmode=require"< create_user.sql
  rm create_user.sql

  # remove access to the database
  az postgres server firewall-rule delete \
    --resource-group $RESOURCE_GROUP \
    --server $ACMEFIT_POSTGRES_SERVER \
    --name allow-current-agent
}

function main() {
  # create_spring_cloud
  # configure_defaults
  # create_dependencies
  # create_builder
  # configure_acs
  # configure_sso
  configure_gateway
  # create_identity_service
  # create_cart_service
  # create_order_service
  # create_payment_service
  # create_catalog_service
  # create_frontend_app

  # create_databaseuser

  # deploy_identity_service
  # deploy_cart_service
  # deploy_order_service 
  # deploy_payment_service 
  # deploy_catalog_service 
  # deploy_frontend_app 
}

function usage() {
  echo 1>&2
  echo "Usage: $0 -g <resource_group> -s <spring_cloud_instance>" 1>&2
  echo 1>&2
  echo "Options:" 1>&2
  echo "  -g <namespace>              the Azure resource group to use for the deployment" 1>&2
  echo "  -s <spring_cloud_instance>  the name of the Azure Spring Cloud Instance to use" 1>&2
  echo 1>&2
  exit 1
}

function check_args() {
  if [[ -z $RESOURCE_GROUP ]]; then
    echo "Provide a valid resource group with -g"
    usage
  fi

  if [[ -z $SPRING_CLOUD_INSTANCE ]]; then
    echo "Provide a valid spring cloud instance name with -s"
    usage
  fi

  if [[ -z $REGION ]]; then
    echo "Provide a valid region with -r"
    usage
  fi
}

while getopts ":g:s:r:" options; do
  case "$options" in
  g)
    RESOURCE_GROUP="$OPTARG"
    ;;
  s)
    SPRING_CLOUD_INSTANCE="$OPTARG"
    ;;
  r)
    REGION="$OPTARG"
    ;;
  *)
    usage
    exit 1
    ;;
  esac

  case $OPTARG in
  -*)
    echo "Option $options needs a valid argument"
    exit 1
    ;;
  esac
done

check_args
main
