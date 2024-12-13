## Deploy the scrapers and automatically upload the data

Let's go back to the sample exporter configuration. We can now add the information related to the database and the scrapers.
```
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: # ExporterScraperConfig name
  namespace: # ExporterScraperConfig namespace
spec:
  exporterConfig:
    ...
  scraperConfig: # configuration for krateoplatformops/finops-operator-scraper
    tableName: # tableName in the database to upload the data to
    # url: # path to the exporter, optional (if missing, its taken from the exporter)
    pollingIntervalHours: # int
    scraperDatabaseConfigRef: # See above kind DatabaseConfig
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
```

Run the following code to create a new YAML configuration file and create the deployment:
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
      key: bearer-token
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
Note: you may get one of the following errors:
```
error: error from server (NotFound): deployments.apps "exporterscraperconfig-sample-scraper-deployment" not found in namespace "finops"
Error from server (BadRequest): container "scraper" in pod "exporterscraperconfig-sample-scraper-deployment-78796bd756fcsw8" is waiting to start: ContainerCreating
```
These are caused by the slow startup time of the exporter/scraper on Killercoda. Wait a few moments, and then try again.
The upload is completed when the scraper stops writing "successfully uploaded" logs.

We can verify the data in CrateDB with a simple notebook to query the database:
```python
def main():   
    table_name_arg = sys.argv[5]
    table_name_key_value = str.split(table_name_arg, '=')
    if len(table_name_key_value) == 2:
        if table_name_key_value[0] == 'table_name':
            table_name = table_name_key_value[1]
    try:
        resource_query = f"SELECT * FROM {table_name}"
        cursor.execute(resource_query)
        raw_data = cursor.fetchall()
        print(raw_data)
    finally:
        cursor.close()
        connection.close()
if __name__ == "__main__":
    main()
```

Let's upload the query notebook to the FinOps Database Handler:
```plain
echo "def main():   
    table_name_arg = sys.argv[5]
    table_name_key_value = str.split(table_name_arg, '=')
    if len(table_name_key_value) == 2:
        if table_name_key_value[0] == 'table_name':
            table_name = table_name_key_value[1]
    try:
        resource_query = f\"SELECT * FROM {table_name}\"
        cursor.execute(resource_query)
        raw_data = cursor.fetchall()
        print(raw_data)
    finally:
        cursor.close()
        connection.close()
if __name__ == \"__main__\":
    main()" > query.py
curl -X POST -u system:$(kubectl get secret user-system-cratedb-cluster -n finops -o json | jq -r '.data.password' | base64 --decode) http://localhost:$(kubectl get service -n finops finops-database-handler -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/compute/query/upload --data-binary "@query.py"
```{{exec}}

Run the notebook:
```plain
curl -X POST -u system:$(kubectl get secret user-system-cratedb-cluster -n finops -o json | jq -r '.data.password' | base64 --decode) http://localhost:$(kubectl get service -n finops finops-database-handler -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/compute/query --header "Content-Type: application/json" --data '{"table_name":"krateo_finops_tutorial"}'
```{{exec}}
