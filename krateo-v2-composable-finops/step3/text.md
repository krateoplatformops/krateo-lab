## Let's deploy an exporter from a static FOCUS cost
We will create a new Custom Resource for the operator-focus, this allows us to encode a cost that does not come from an API. It will result in the creation of an exporter, a configmap containing the data for the exporter, a service to expose the exporter and a custom resource for the operator-scraper. The exporter will use the Kubernetes API server as the endpoint.

Let's start from the bare config-sample.yaml in the repository finops-operator-focus.

We will only consider the exporting for this step.
```yaml
apiVersion: finops.krateo.io/v1
kind: FocusConfig
metadata:
  name: # FocusConfig name
  namespace: # FocusConfig namespace
spec:
  scraperConfig: # same fields as krateoplatformops/finops-prometheus-scraper-generic
    tableName: # tableName in the database to upload the data to
    # url: # path to the exporter, optional (if missing, its taken from the exporter)
    pollingIntervalHours: # int
    scraperDatabaseConfigRef: # See above kind DatabaseConfig
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
  focusSpec: # See FOCUS for field details
    availabilityZone:
    billedCost:
    billingAccountId:
    billingAccountName:
    billingCurrency:
    billingPeriodEnd:
    billingPeriodStart:
    ...
    resourceName:
    resourceType:
    serviceCategory:
    serviceName:
    skuId:
    skuPriceId:
    subAccountId:
    subAccountName:
    tags:
      - key:
        value:
```
The custom resource contains the scraper configuration, just like the ExporterScraperConfig, but instead of requiring the configuration of the endpoint to export data from, it requires the data itself. The data is encoded following the FinOps Cost and Usage Specification, FOCUS.

Run the following code to create a sample resource (omitting the scraper configuration): 
```plain
cat <<EOF | kubectl apply -f -
apiVersion: finops.krateo.io/v1
kind: FocusConfig
metadata:
  name: focusconfig-sample
  namespace: krateo-system
spec:
  focusSpec:
    availabilityZone: "EU"
    billedCost: 30000.0
    billingAccountId: "0000"
    billingAccountName: "testAccount"
    billingCurrency: "EUR"
    billingPeriodStart: "2024-01-01T00:00:00+02:00"
    billingPeriodEnd: "2024-12-31T23:59:59+02:00"
    chargeCategory: "purchase"
    chargeDescription: "1 Dell XYZ"
    chargeFrequency: "one-time"
    chargePeriodEnd: "2024-12-31T23:59:59+02:00"
    chargePeriodStart: "2024-01-01T00:00:00+02:00"
    consumedUnit: "Computer"
    consumedQuantity: "3"
    contractedCost: 30000
    contractedUnitCost: 10000
    effectiveCost: 30000.0
    invoiceIssuerName: "Dell"
    listCost: 30000.0
    listUnitPrice: 10000.0
    pricingCategory: "other"
    pricingQuantity: 3
    pricingUnit: "machines"
    providerName: "Dell"
    publisherName: "Dell"
    resourceId: "0000"
    resourceName: "Dell HW"
    resourceType: "Prod Cluster"
    serviceCategory: "Compute"
    serviceName: "1 machine purchase"
    skuId: "0000"
    skuPriceId: "0000"
    subAccountId: "1234"
    subAccountName: "test"
    tags:
      - key: "testkey1"
        value: "testvalue"
      - key: "testkey2"
        value: "testvalue"
EOF
```{{exec}}

Let's wait for the deployment to be available
```plain
kubectl wait deployment -n krateo-system all-cr-exporter-deployment --for condition=Available=True --timeout=300s
```{{exec}}

You can now verify the exporter output with:
```plain
curl localhost:$(kubectl get service -n krateo-system all-cr-exporter-service -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/metrics 
```{{exec}}
