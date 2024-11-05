## Deploy the scrapers and automatically upload the data
Let's go back to the sample exporter configuration. We can now add the information related to the database for the scrapers.

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
  scraperConfig: # configuration for krateoplatformops/finops-operator-scraper
    tableName: # tableName in the database to upload the data to
    # url: # path to the exporter, optional (if missing, its taken from the exporter)
    pollingIntervalHours: # int
    scraperDatabaseConfigRef: # See above kind DatabaseConfig
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
```

Run the following to create a new yaml configuration file and create the deployment.

```plain
echo "apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: exporterscraperconfig-sample
  namespace: finops
spec:
  exporterConfig:
    provider: 
      name: azure
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
      port: WEBSERVICE_API_MOCK_SERVICE_PORT
  scraperConfig:
    tableName: krateo_finops_tutorial
    pollingIntervalHours: 1
    scraperDatabaseConfigRef:
      name:  finops-tutorial-config
      namespace: finops" > sample.yaml
kubectl delete -f sample.yaml
kubectl apply -f sample.yaml
```{{exec}}

The upload may take some time. Check when it's terminated with:
```plain
kubectl logs -n finops -f deployment/exporterscraperconfig-sample-scraper-deployment
```{{exec}}

You can verify the data in the SQL warehouse with a simple select. Make sure to select the correct catalog or enter the full path in the table name.

```
SELECT * FROM krateo-finops-tutorial
```
