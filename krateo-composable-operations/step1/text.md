# Krateo Core Provider

Manage Krateo PlatformOps Compositions.

## What is a Composition?

A Composition is an Helm Chart archive (.tgz) with a [JSON Schema](https://json-schema.org/) for the [`values.yaml`](https://helm.sh/docs/chart_template_guide/values_files/) file.

This [JSON Schema](https://json-schema.org/) file must be named: `values.schema.json`.

There are many online tools to generate automatically [JSON Schema](https://json-schema.org/) from YAML, here a few:

- https://jsonformatter.org/yaml-to-jsonschema
- https://codebeautify.org/yaml-to-json-schema-generator

Here some online tools useful to verify the [JSON Schema](https://json-schema.org/) before building the Composition:

- https://www.jsonschemavalidator.net/
- https://json-schema.hyperjump.io/

## What is a Definition?

A Definition is the Krateo Custom Resource that takes the Helm Chart specified within the Kubernetes manifest and automatically:
- generates a Custom Resource Definition that represents the values.schema.json file from the Helm chart
- instantiates a Deployment that watches any new Custom Resource that represents the values.yaml from the Helm Chart

## Install core-provider
First we make sure we add Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

We can update the repo

```plain
helm repo update
```{{exec}}

Now we install the chart

```plain
helm install krateo-core-provider krateo/core-provider --create-namespace --namespace krateo-system --version 0.7.4
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment core-provider --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}

## Resources (specs)

## core.krateo.io/v1alpha1, Definition

A `Definition` defines a Krateo Composition Archive URL.

| Spec               | Description                                     | Required |
|:-------------------|:------------------------------------------------|:---------|
| chart.url          | krateo composition url                          | true     |
| chart.version      | krateo composition version                      | false    |
| chart.repo         | helm chart repo name (only for helm repos urls) | false    |
