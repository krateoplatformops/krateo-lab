## Let's deploy an exporter from an API endpoint
We will create a new Custom Resource for the operator-exporter, this will result in the creation of an exporter, a configmap containing the data for the exporter, a service to expose the exporter and a custom resource for the operator-scraper.

Let's start from the bare config-sample.yaml in the repository finops-operator-exporter.

We will only consider the exporterConfig for this step. The sample is organized as follows:
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
    api: # the API to call
      path: # the path inside the domain
      verb: GET # the method to call the API with
      endpointRef: # secret with the url in the format http(s)://host:port, it can contain variables, such as http://<varName>.com:<envExample>, which will be compiled with the additionalVariables fields
        name: 
        namespace:
    # metricType: # optional, one of: cost, resource; default value: cost
    pollingInterval: # time duration, e.g., 12h30m
    additionalVariables:
      varName: sample
      # Variables whose value only contains uppercase letters are taken from environment variables
      # FROM_THE_ENVIRONMENT must be the name of an environment variable inside the target exporter container (e.g., kubernetes services)
      envExample: FROM_THE_ENVIRONMENT
  scraperConfig: # same fields as krateoplatformops/finops-prometheus-scraper-generic
    tableName: # tableName in the database to upload the data to
    # api: # api to the exporter, optional (if missing, it uses the exporter)
    pollingInterval: # time duration, e.g., 12h30m
    scraperDatabaseConfigRef: # See above kind DatabaseConfig
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
```
Each field is explained by the comment.

The following code creates a new CR to connect to a mock API server in the cluster:
```plain
cat <<EOF | kubectl apply -f -
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: exporterscraperconfig-sample
  namespace: krateo-system
spec:
  exporterConfig:
    api: 
      path: /subscriptions/<subscription_id>/providers/Microsoft.Consumption/usageDetails
      verb: GET
      endpointRef:
        name: webservice-mock-endpoint
        namespace: krateo-system
    metricType: cost
    pollingInterval: "1h"
    additionalVariables:
      subscription_id: d3sad326-42a4-5434-9623-a3sd22fefb84
      host: WEBSERVICE_API_MOCK_SERVICE_HOST
      port: WEBSERVICE_API_MOCK_SERVICE_PORT
EOF
```{{exec}}

Let's wait for the operator to create the deployment and for it to be available:
```plain
kubectl wait deployment -n krateo-system exporterscraperconfig-sample-deployment --for condition=Available=True --timeout=300s
```{{exec}}

You can now verify the exporter output with:
```plain
curl localhost:$(kubectl get service -n krateo-system exporterscraperconfig-sample-service -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/metrics 
```{{exec}}
