# Krateo Core Provider

Manage Krateo PlatformOps Compositions.

## What is a Composition?

A Composition is an Helm Chart archive (.tgz) with a [JSON Schema](https://json-schema.org/) for the [`values.yaml`](https://helm.sh/docs/chart_template_guide/values_files/) file.

This [JSON Schema](https://json-schema.org/) file must be named: `values.schema.json`.

There are many online tools to generate automatically [JSON Schema](https://json-schema.org/) from YAML, here are a few:

- https://jsonformatter.org/yaml-to-jsonschema
- https://codebeautify.org/yaml-to-json-schema-generator

Here are some online tools useful to verify the [JSON Schema](https://json-schema.org/) before building the Composition:

- https://www.jsonschemavalidator.net/
- https://json-schema.hyperjump.io/

## What is a CompositionDefinition?

A CompositionDefinition is the Krateo Custom Resource that takes the Helm Chart specified within the Kubernetes manifest and automatically:
- generates a Custom Resource Definition that represents the values.schema.json file from the Helm chart
- instantiates a Deployment that watches any new Custom Resource that represents the values.yaml from the Helm Chart

## Install core-provider
First, we make sure we add the Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

We can update the repo

```plain
helm repo update
```{{exec}}

Now we install the chart

```plain
helm install core-provider krateo/core-provider --create-namespace --namespace krateo-system --version 0.15.1
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment core-provider --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}
