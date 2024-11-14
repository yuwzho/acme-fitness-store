## Introduction

This document provides instructions on how to view logs and metrics for your Azure Kubernetes Service (AKS) cluster. By following these steps, you will be able to monitor your containerized applications effectively. For more details, see [Monitor AKS](https://learn.microsoft.com/en-us/azure/aks/monitor-aks).

## Prerequisites
- Follow [Create Kubernetes Service](./01-create-kubernetes-service.md) to create the Azure Kubernetes Service.
  - If you have your own Azure Kubernetes Service, see [Enable monitoring for Kubernetes clusters](https://learn.microsoft.com/azure/azure-monitor/containers/kubernetes-monitoring-enable) to enable Managed Prometheus and Container insights on your cluster.
- Deploy at least one application on the Azure Kubernetes Service from previous guidance.

## Steps

### 1. View Logs

Go to Azure Portal and click the AKS. On the left blade, click Logs and then run a query to get the container logs. The logs are stored in the table "ContainerLogV2". This document describes the schema: [Container Insights Logs Schema](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-logs-schema).

### 2. View Metrics

Go to Azure Portal and click the AKS. On the left blade, click Insights and view the metrics for the nodes, pods, and containers. More details can be found in [Container Insights Analyze](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-analyze).

#### Grant access to view metrics
If you get a 403 error when viewing the metrics, you need to grant yourself access to view them. To enable access to view application metrics through the dashboard, see [Use Kubernetes role-based access control with Microsoft Entra ID in Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/azure-ad-rbac?tabs=azure-cli).