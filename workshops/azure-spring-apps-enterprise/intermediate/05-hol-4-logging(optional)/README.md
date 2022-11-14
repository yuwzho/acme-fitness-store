This is an optional exercise for the students. 

Open the Log Analytics that you created - you can find the Log Analytics in the same
Resource Group where you created an Azure Spring Apps service instance.

In the Log Analytics page, selects `Logs` blade and run any of the sample queries supplied below
for Azure Spring Apps.

Type and run the following Kusto query to see application logs:

```sql
    AppPlatformLogsforSpring 
    | where TimeGenerated > ago(24h) 
    | limit 500
    | sort by TimeGenerated
    | project TimeGenerated, AppName, Log
```

![Example output from all application logs query](../../../../media/all-app-logs-in-log-analytics.jpg)

Type and run the following Kusto query to see `catalog-service` application logs:

```sql
    AppPlatformLogsforSpring 
    | where AppName has "catalog-service"
    | limit 500
    | sort by TimeGenerated
    | project TimeGenerated, AppName, Log
```

![Example output from catalog service logs](../../../../media/catalog-app-logs-in-log-analytics.jpg)

Type and run the following Kusto query to see errors and exceptions thrown by each app:
```sql
    AppPlatformLogsforSpring 
    | where Log contains "error" or Log contains "exception"
    | extend FullAppName = strcat(ServiceName, "/", AppName)
    | summarize count_per_app = count() by FullAppName, ServiceName, AppName, _ResourceId
    | sort by count_per_app desc 
    | render piechart
```

![An example output from the Ingress Logs](../../../../media/ingress-logs-in-log-analytics.jpg)

Type and run the following Kusto query to see all in the inbound calls into Azure Spring Apps:

```sql
    AppPlatformIngressLogs
    | project TimeGenerated, RemoteAddr, Host, Request, Status, BodyBytesSent, RequestTime, ReqId, RequestHeaders
    | sort by TimeGenerated
```

Type and run the following Kusto query to see all the logs from Spring Cloud Gateway managed by Azure Spring Apps:

```sql
    AppPlatformSystemLogs
    | where LogType contains "SpringCloudGateway"
    | project TimeGenerated,Log
```

![An example out from the Spring Cloud Gateway Logs](../../../../media/spring-cloud-gateway-logs-in-log-analytics.jpg)

Type and run the following Kusto query to see all the logs from Spring Cloud Service Registry managed by Azure Spring Apps:

```sql
    AppPlatformSystemLogs
    | where LogType contains "ServiceRegistry"
    | project TimeGenerated, Log
```

![An example output from service registry logs](../../../../media/service-registry-logs-in-log-analytics.jpg)


⬅️ Previous guide: [04 - Hands On Lab 3 - Deploy backend apps](../04-hol-3-deploy-backend-apps/README.md)

➡️ Workshop Start: [01 - Workshop Environment Setup](../01-workshop-environment-setup/README.md)