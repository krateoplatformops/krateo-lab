## Let's deploy an exporter from a static FOCUS cost
We will create a new Custom Resource for the operator-focus, this will result in the creation of an exporter, a configmap containing the data for the exporter, a service to expose the exporter and a custom resource for the operator-scraper.

Let's start from the bare config-sample.yaml in the repository finops-operator-focus.

We will only consider the exporterConfig for this tutorial.
sample-config.yaml:
```
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
    chargeCategory:
    chargeClass:
    chargeDescription:
    chargeFrequency:
    chargePeriodEnd:
    chargePeriodStart:
    commitmentDiscountCategory:
    commitmentDiscountName:
    commitmentDiscountStatus:
    commitmentDiscountType:
    commitmentDiscoutId:
    consumedQuantity:
    consumedUnit:
    contractedCost:
    contractedUnitCost:
    effectiveCost:
    invoiceIssuerName:
    listCost:
    listUnitPrice:
    pricingCategory:
    pricingQuantity:
    pricingUnit:
    providerName:
    publisherName:
    regionId:
    regionName:
    resourceId:
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

Compile the CR as follows to create a sample resource: 
As usual, we omit the scraper configuration for this tutorial.
```plain
echo "apiVersion: finops.krateo.io/v1
kind: FocusConfig
metadata:
  name: focusconfig-sample
  namespace: finops
spec:
  focusSpec:
    availabilityZone: \"EU\"
    billedCost: 30000.0
    billingAccountId: \"0000\"
    billingAccountName: \"testAccount\"
    billingCurrency: \"EUR\"
    billingPeriodStart: \"2024-01-01T00:00:00+02:00\"
    billingPeriodEnd: \"2024-12-31T23:59:59+02:00\"
    chargeCategory: \"purchase\"
    chargeDescription: \"1 Dell XYZ\"
    chargeFrequency: \"one-time\"
    chargePeriodEnd: \"2024-12-31T23:59:59+02:00\"
    chargePeriodStart: \"2024-01-01T00:00:00+02:00\"
    consumedUnit: \"Computer\"
    consumedQuantity: \"3\"
    contractedCost: 30000
    contractedUnitCost: 10000
    effectiveCost: 30000.0
    invoiceIssuerName: \"Dell\"
    listCost: 30000.0
    listUnitPrice: 10000.0
    pricingCategory: \"other\"
    pricingQuantity: 3
    pricingUnit: \"machines\"
    providerName: \"Dell\"
    publisherName: \"Dell\"
    resourceId: \"0000\"
    resourceName: \"Dell HW\"
    resourceType: \"Prod Cluster\"
    serviceCategory: \"Compute\"
    serviceName: \"1 machine purchase\"
    skuId: \"0000\"
    skuPriceId: \"0000\"
    subAccountId: \"1234\"
    subAccountName: \"test\"
    tags:
      - key: \"testkey1\"
        value: \"testvalue\"
      - key: \"testkey2\"
        value: \"testvalue\" " > sample.yaml
```{{exec}}

Deploy the sample configuration:
```plain
kubectl apply -f sample.yaml
```{{exec}}

Let's wait for the deployment to be available
```plain
kubectl wait deployment -n finops all-cr-exporter-deployment --for condition=Available=True --timeout=300s
```{{exec}}

You can now verify the exporter output with:
```plain
curl localhost:$(kubectl get service -n finops all-cr-exporter-service -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/metrics 
```{{exec}}
