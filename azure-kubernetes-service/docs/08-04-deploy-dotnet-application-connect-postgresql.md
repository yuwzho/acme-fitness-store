---
Owner: Yuwei
Prerequisites:
- AKS
- Redis
- PostgreSQL
Output:
- Template to deploy the application to cluster
- How to pull the image from ACR to cluster
- Config service endpoint to find each other
---

## Order Service

### Create database for order and save to Kubernetes

Will use Workload Identity for application to access PostgreSQL passwordlessly. For more details, see https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster

### Create managed identity


1. Create identity

```
az identity create -n acme-order-identity -g yuwzho-acme --location eastus2 --subscription a4ab3025-1b32-4394-92e0-d07c1ebf3787
```

###  Connect the managed identity to postgres


1. Create Database
   ```
   az postgres flexible-server db create --database-name acme-order -g yuwzho-acme -s yuwzho-acme-postgre
   ```

1. Upgrade the extension
   ```
   az extension add --name serviceconnector-passwordless --upgrade
   ```

1. Create the  connection
   ```
   AKS_ID=$(az aks show --resource-group yuwzho-acme --name yuwzho-acme-k8s --query id -o tsv)
   DATABASE_ID=$(az postgres flexible-server db show --database-name acme-order -g yuwzho-acme -s yuwzho-acme-postgre --query id -o tsv)
   IDENTITY_ID=$(az identity show -n acme-order-identity -g yuwzho-acme --query id -o tsv)
   az aks connection create postgres-flexible --connection order_acme_postgres --source-id ${AKS_ID} --target-id ${DATABASE_ID} --client-type dotnet --workload-identity ${IDENTITY_ID}
   ```

## Deploy the acme-order service
1. Get the service account information created by service connection.
   ```
   az aks connection show --connection order_acme_postgres -g yuwzho-acme -n yuwzho-acme-k8s --query kubernetesResourceName
   ```

   Note there should be 2 resources created:
   - `sc-<connection-name>-secret`: Stores the environment variables indicating the PostgreSQL instance, these values can be read by the .NET application.
   - `sc-account-<client-id>`: Service Account that can be used by Kubernetes resources to authenticate the managed identity, then to get the access that the managed identity has.

1. Update `resources/applications/acme-order.yml`
Replace `sc-<connection-name>-secret` and `sc-account-<client-id>` with the values obtained from the previous step.

1. Update `resources/applications/acme-order.yml`
Replace `sc-<connection-name>-secret` and `sc-account-<client-id>` with the values obtained from the previous step.

1. Apply the resource
  ```
  kubectl apply -f resources/applications/acme-order.yml
  ```