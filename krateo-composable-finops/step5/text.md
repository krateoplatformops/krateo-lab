## Let's deploy an exporter from a static FOCUS cost
We will create a new Custom Resource for the operator-focus, this will result in the creation of an exporter, a configmap containing the data for the exporter, a service to expose the exporter and a custom resource for the operator-scraper.

Let's start from the bare config-sample.yaml in the repository finops-operator-focus.
```plain
cd ../finops-operator-focus
```{{exec}}

We will only consider the exporterConfig for this tutorial.
sample-config.yaml:
```plain
apiVersion: finops.krateo.io/v1
kind: FocusConfig
metadata:
  labels:
    app.kubernetes.io/name: focusconfig
    app.kubernetes.io/instance: focusconfig-sample
    app.kubernetes.io/part-of: operator-focus
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: operator-focus
  name: focusconfig-sample2
  namespace: finops
spec:
  scraperConfig: # same fields as krateoplatformops/finops-prometheus-scraper-generic
    tableName: # tableName in the database to upload the data to
    # url: # path to the exporter, optional (if missing, its taken from the exporter)
    pollingIntervalHours: # int
    scraperDatabaseConfigRef: # See above kind DatabaseConfig
      name: # name of the databaseConfigRef CR 
      namespace: # namespace of the databaseConfigRef CR
  focusSpec: # See FOCUS for field details
    region:
    availabilityZone:
    billedCost:
    billingAccountId:
    billingAccountName:
    billingCurrency:
    billingPeriodStart:
    billingPeriodEnd:
    chargeCategory:
    chargeDescription:
    chargeFrequency:
    chargeSubCategory:
    chargePeriodStart:
    chargePeriodEnd:
    effectiveCost:
    listCost:
    listUnitPrice:
    pricingCategory:
    pricingQuantity:
    pricingUnit:
    invoiceIssuer:
    provider:
    publisher:
    resourceId:
    resourceName:
    resourceType:
    serviceName:
    serviceCategory:
    subAccountId:
    subAccountName:
    skuId:
    skuPriceId:
    tags:
      - key:
        value:
    usageQuantity:
    usageUnit: 
```

Compile the CR as follows to create a sample resource: 
As usual, we omit the scraper configuration for this tutorial.
```plain
echo "apiVersion: finops.krateo.io/v1
kind: FocusConfig
metadata:
  labels:
    app.kubernetes.io/name: focusconfig
    app.kubernetes.io/instance: focusconfig-sample
    app.kubernetes.io/part-of: operator-focus
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: operator-focus
  name: focusconfig-sample
  namespace: finops
spec:
  focusSpec:
    region: \"EU\"
    availabilityZone: \"EU2\"
    billedCost: 30020.0
    billingAccountId: \"0000\"
    billingAccountName: \"testAccount\"
    billingCurrency: \"EUR\"
    billingPeriodStart: \"2024-01-01T00:00:00+02:00\"
    billingPeriodEnd: \"2024-12-31T23:59:59+02:00\"
    chargeCategory: \"purchase\"
    chargeDescription: \"1 Dell XYZ\"
    chargeFrequency: \"one-time\"
    chargeSubCategory: \"On-Demand\"
    chargePeriodStart: \"2024-01-01T00:00:00+02:00\"
    chargePeriodEnd: \"2024-12-31T23:59:59+02:00\"
    effectiveCost: 30000.0
    listCost: 30000.0
    listUnitPrice: 10000.0
    pricingCategory: \"other\"
    pricingQuantity: 3
    pricingUnit: \"machines\"
    invoiceIssuer: \"Dell\"
    provider: \"Dell\"
    publisher: \"Dell\"
    resourceId: \"0000\"
    resourceName: \"Dell HW\"
    resourceType: \"Prod Cluster\"
    serviceName: \"1 machine purchase\"
    serviceCategory: \"Compute\"
    subAccountId: \"1234\"
    subAccountName: \"test\"
    skuId: \"0000\"
    skuPriceId: \"0000\"
    tags:
      - key: \"testkey1\"
        value: \"testvalue\"
      - key: \"testkey2\"
        value: \"testvalue\"
    usageQuantity: 1
    usageUnit: \"none\" " > sample.yaml
```{{exec}}

Deploy the sample configuration:
```plain
kubectl apply -f sample.yaml
```{{exec}}

Let's wait for the deployment to be available
```plain
kubectl wait deployment focusconfig-sample-deployment --for condition=Available=True --timeout=300s
```{{exec}}

You can now verify the exporter output with:
```plain
curl localhost:$(kubectl get service focusconfig-sample-service -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/metrics 
```{{exec}}
