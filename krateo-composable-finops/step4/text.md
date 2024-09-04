## Let's deploy an exporter from an API endpoint
We will create a new Custom Resource for the operator-exporter, this will result in the creation of an exporter, a configmap containing the data for the exporter, a service to expose the exporter and a custom resource for the operator-scraper.

Let's start from the bare config-sample.yaml in the repository finops-operator-exporter.

We will only consider the exporterConfig for this tutorial.
sample-config.yaml:
```
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: # ExporterScraperConfig name
  namespace: # ExporterScraperConfig namespace
spec:
  exporterConfig: # same as krateoplatformops/finops-prometheus-exporter-generic
    provider: 
      name: # name of the provider config
      namespace: # namespace of the provider config
    url: # url including http/https of the CSV-based API to export, parts with <varName> are taken from additionalVariables: http://<varName> -> http://sample 
    requireAuthentication: # true/false
    authenticationMethod: # one of: bearer-token, cert-file
    # bearerToken: # optional, if "authenticationMethod: bearer-token", objectRef to a standard Kubernetes secret with key: bearer-token
    #  name: # secret name
    #  namespace: # secret namespace
    # metricType: # optional, one of: cost, resource; default value: resource
    pollingIntervalHours: # int
    additionalVariables:
      varName: sample
      # Variables whose value only contains uppercase letters are taken from environment variables
      # FROM_THE_ENVIRONMENT must be the name of an environment variable inside the target exporter container
      envExample: FROM_THE_ENVIRONMENT
```

Compile the CR as follows to connect to a mock API server in the cluster:
```plain
echo "apiVersion: v1
kind: Secret
metadata:
  name: mock-token
  namespace: finops
data:
  bearer-token: bW9ja3Rva2Vu
---
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: exporterscraperconfig-sample
  namespace: finops
spec:
  exporterConfig:
    provider: 
      name: not_used
      namespace: finops
    url: http://<host>:<port>/subscriptions/<subscription_id>/providers/Microsoft.Consumption/usageDetails
    requireAuthentication: true
    authenticationMethod: bearer-token
    bearerToken:
      name: mock-token
      namespace: finops
    metricType: cost
    pollingIntervalHours: 1
    additionalVariables:
      # Variables that contain only uppercase letters are taken from environment variables
      subscription_id: d3sad326-42a4-5434-9623-a3sd22fefb84
      host: WEBSERVICE_API_MOCK_SERVICE_HOST
      port: WEBSERVICE_API_MOCK_SERVICE_PORT" > sample.yaml
```{{exec}}

Deploy the sample configuration:
```plain
kubectl apply -f sample.yaml
```{{exec}}

Let's wait for the deployment to be available
```plain
kubectl wait deployment -n finops exporterscraperconfig-sample-deployment --for condition=Available=True --timeout=300s
```{{exec}}

You can now verify the exporter output with:
```plain
curl localhost:$(kubectl get service -n finops exporterscraperconfig-sample-service -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/metrics 
```{{exec}}
