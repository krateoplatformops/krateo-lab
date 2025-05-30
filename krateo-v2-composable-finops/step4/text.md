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
      path: /providers/microsoft.insights/metrics?api-version=2023-10-01&metricnames=Percentage%20CPU&timespan=2025-04-01/2025-05-01&interval=PT15M
      verb: GET
      endpointRef:
        name: webservice-mock-endpoint
        namespace: krateo-system
    metricType: resource
    pollingInterval: "1h"
    additionalVariables:
      ResourceId: /subscriptions/1caaa5a3-2b66-438e-8ab4-bce37d518c5d/resourcegroups/mar-ccm/providers/microsoft.compute/virtualmachines/mar-ccm-vm01
  scraperConfig:
    pollingInterval: "1h"
    tableName: finops_res
    scraperDatabaseConfigRef:
      name: finops-database-handler
      namespace: krateo-system
EOF
```{{exec}}

You can proceed to the creation of the combined exporter/scraper configuration.