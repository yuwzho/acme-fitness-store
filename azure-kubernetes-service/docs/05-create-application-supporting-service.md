---
Onwer: Yuwei
Prerequisites:
Output:
- Redis
- PostgreSQL
---

## Create PostgreSQL

1. Get AKS outbount IPs and note these IPs as `<AKS-outbound-ip>`
```
az aks show -g  yuwzho-acme -n yuwzho-acme-k8s --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id
az resource show --ids <the ID from previous output> --query properties.ipAddress -o tsv
```

1. Create Postgresql Flexible server and enable the access from Kubernetes
```
az postgres flexible-server create -g yuwzho-acme -n yuwzho-acme-postgre --active-directory-auth Enabled --password-auth Disabled --public-access <AKS-outbound-ip>
```

1. Add yourself into the server admin for further settings
```
USER_ME_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv)
USER_ME_ID=$(az ad signed-in-user show --query id -o tsv)
az postgres flexible-server ad-admin create --server-name yuwzho-acme-postgre --resource-group yuwzho-acme --display-name ${USER_ME_NAME} --object-id ${USER_ME_ID}
```

## Create Redis Cache
```
az redis create -n yuwzho-acme-redis -g  yuwzho-acme --sku Basic --vm-size c0 -l eastus2
```