## Let's configure the Custom Usage Metrics

When we obtain a FOCUS report, we can analyze it to identify the resources that are generating costs. To configure the resource usage metrics and obtain the relevant metrics, we need to create an additional ExporterScraperConfig configured for usage metrics:
```plain
cat <<EOF | kubectl apply -f -
apiVersion: finops.krateo.io/v1
kind: ExporterScraperConfig
metadata:
  name: exporterscraperconfig-sample-res
  namespace: krateo-system
spec:
  exporterConfig:
    api: 
      path: /metrics
      verb: GET
      endpointRef:
        name: webservice-mock-endpoint
        namespace: krateo-system
    metricType: resource
    pollingInterval: "1h"
    additionalVariables:
      ResourceId: /subscriptions/d3sad326-42a4-5434-9623-a3sd22fefb84/resourcegroups/mar-ccm/providers/microsoft.compute/virtualmachines/mar-ccm-vm01
      host: WEBSERVICE_API_MOCK_SERVICE_HOST
      port: WEBSERVICE_API_MOCK_SERVICE_PORT
  scraperConfig:
    tableName: krateo_finops_tutorial_res
    pollingInterval: "1h"
    scraperDatabaseConfigRef:
      name: finops-database-handler
      namespace: krateo-system
EOF
```{{exec}}

You can proceed to the creation of the combined exporter/scraper configuration.

For a blueprint version configured for an Azure VM, check out this [template](https://github.com/krateoplatformops-blueprints/azure-vm-finops/blob/main/blueprint/templates/exporterscraperconfig.yaml).