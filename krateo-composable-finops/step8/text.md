## Deploy the scrapers and automatically upload the data
Let's go back to the sample exporter configuration. We can now add the information related to the database for the scrapers.

```
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  labels:
    app.kubernetes.io/name: exporterscraperconfig
    app.kubernetes.io/instance: exporterscraperconfig-sample
    app.kubernetes.io/part-of: operator-exporter
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: operator-exporter
  name: exporterscraperconfig-sample
  namespace: finops
spec:
  exporterConfig:
    provider: 
      name: # name of the provider configuration object created in the previous step azure
      namespace: # namespace
    url: http://<host>:<port>/subscriptions/<subscription_id>/providers/Microsoft.Consumption/usageDetails
    requireAuthentication: true
    authenticationMethod: # bearer-token; cert-file
    pollingIntervalHours: 1
    additionalVariables:
      # Variables that contain only uppercase letters are taken from environment variables
      subscription_id: d3sad326-42a4-5434-9623-a3sd22fefb84
      authenticationToken: 123456abc
      host: WEBSERVICE_API_MOCK_SERVICE_HOST
      port: WEBSERVICE_API_MOCK_SERVICE_PORT
  scraperConfig: # same fields as krateoplatformops/finops-prometheus-scraper-generic
    tableName: # tableName in the database to upload the data to
    # url: # path to the exporter, optional (if missing, its taken from the exporter)
    pollingIntervalHours: # int
    scraperDatabaseConfigRef:
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
```

Run the following to create a new yaml configuration file and create the deployment.

```plain
echo "apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  labels:
    app.kubernetes.io/name: exporterscraperconfig
    app.kubernetes.io/instance: exporterscraperconfig-sample
    app.kubernetes.io/part-of: operator-exporter
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: operator-exporter
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
    pollingIntervalHours: 1
    additionalVariables:
      # Variables that contain only uppercase letters are taken from environment variables
      subscription_id: d3sad326-42a4-5434-9623-a3sd22fefb84
      authenticationToken: 123456abc
      host: WEBSERVICE_API_MOCK_SERVICE_HOST
      port: WEBSERVICE_API_MOCK_SERVICE_PORT
  scraperConfig: # same fields as krateoplatformops/finops-prometheus-scraper-generic
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
