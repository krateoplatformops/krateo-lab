## Let's configure the Azure Databricks notebook - credentials input

Input your data in the following configuration script:
```plain
./database-input.sh
```{{exec}}

Then apply the configuration of the database to the cluster:
```plain
kubectl apply -f database.yaml
```{{exec}}

We also need to add the resource metrics configuration: when we obtain a FOCUS report, we can analyze it to identify the resources that are generating costs and obtain the relevant metrics. These metrics are specified by provider and resource, through dedicated custom resources with the following structure:
```
apiVersion: finops.krateo.io/v1
kind: ProviderConfig
metadata:
  name: # name
  namespace: # namespace
spec:
  resourcesRef: # list of references to the resource types to scrape
  - name: # name of the first resource type ref 
    namespace: # namespace
---
apiVersion: finops.krateo.io/v1
kind: ResourceConfig
metadata:
  name: # resource type ref 
  namespace: # namespace
spec:
  resourceFocusName: # name of the resource in the FOCUS report, such as "Virtual machine"
  metricsRef: # list of metrics to scrape for this specific resource type
  - name: # name of the first metric type ref
    namespace: # namespace 
---
apiVersion: finops.krateo.io/v1
kind: MetricConfig
metadata:
  name: # metric object name
  namespace: # namespace
spec:
  metricName: # metric name 
  endpoint:
    resourcePrefix: # information to add before the resource path, such as the API url
    resourceSuffix: # information to add after the resource path, such as query parameters
  timespan: # timespan, such as month, day, hour
  interval: # data granularity
```

The following custom resources enable the scraping of the CPU metrics for Virtual Machines on Azure. Let's apply them to the cluster:
```plain
echo "apiVersion: finops.krateo.io/v1
kind: ProviderConfig
metadata:
  name: azure
  namespace: finops
spec:
  resourcesRef:
  - name: azure-virtual-machines
    namespace: finops
---
apiVersion: finops.krateo.io/v1
kind: ResourceConfig
metadata:
  name: azure-virtual-machines
  namespace: finops
spec:
  resourceFocusName: Virtual machine
  metricsRef:
  - name: azure-vm-cpu-usage
    namespace: finops
---
apiVersion: finops.krateo.io/v1
kind: MetricConfig
metadata:
  name: azure-vm-cpu-usage
  namespace: finops
spec:
  metricName: Percentage CPU
  endpoint:
    resourcePrefix: unused for now
    resourceSuffix: /providers/microsoft.insights/metrics?api-version=2023-10-01&metricnames=%s&timespan=%s&interval=%s
  timespan: month
  interval: PT15M" > provider_config.yaml
kubectl apply -f provider_config.yaml
```{{exec}}

You can proceed to the creation of the combined exporter/scraper configuration.
