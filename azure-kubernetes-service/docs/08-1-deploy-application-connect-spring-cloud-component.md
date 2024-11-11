## Deploying the Application

To deploy the application, use the following command:

```sh
kubectl apply -f resources/applications/acme-payment.yml
```

This command will create the following Kubernetes resources:

1. **ConfigMap**: `payment-config`
   - Stores configuration data for the payment service.
   - Contains environment variables such as `EUREKA_CLIENT_ENABLED`.

2. **Deployment**: `payment`
   - Manages the deployment of the payment application.
   - Retrieves environment variables from the `config-server-config` and `eureka-server-config` ConfigMaps. That helps the application connect to Spring Cloud components.
   - Uses the `payment-config` ConfigMap for additional configuration, this configmap can store the environment variables that want to send to the application. Note once the configmap updated, the deployment need to be restart to take effect.
   - Configures probes for liveness and readiness to ensure the application is running correctly.
   - Specifies resource limits and requests for CPU, memory, and ephemeral storage.

3. **Service**: `payment`
   - Exposes the payment application within the Kubernetes cluster.
   - Uses a `ClusterIP` type to provide a stable internal IP address.
   - Routes traffic on port 80 to the application's container port 8080.

