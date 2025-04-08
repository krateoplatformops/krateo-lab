# Install Krateo
To install Krateo, we will follow the [official Krateo Documentation](https://docs.krateo.io/how-to-guides/install-krateo/installing-krateo-kind).

```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm upgrade installer installer \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.4.1 \
  --wait
```{{exec}}

Wait for Krateo to be ready:
```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
```{{exec}}
This step might take upwards of 10 minutes, go grab a coffee in the meantime or learn more about `core-provider`!

# Learn about Krateo Core Provider

Krateo Core Provider is a system for managing Krateo PlatformOps Compositions.

## Core Concepts

### What is a Composition?

A Composition in Krateo is an Helm Chart archive (.tgz) with specific requirements:
- Must include a JSON Schema for the `values.yaml` file
- The schema file must be named `values.schema.json`

#### JSON Schema Tools

You can use these online tools to generate JSON Schema from YAML:
- [YAML to JSON Schema Converter](https://jsonformatter.org/yaml-to-jsonschema)
- [Code Beautify YAML to JSON Schema Generator](https://codebeautify.org/yaml-to-json-schema-generator)

To validate your JSON Schema, you can use:
- [JSON Schema Validator](https://www.jsonschemavalidator.net/)
- [Hyperjump JSON Schema](https://json-schema.hyperjump.io/)

### What is a CompositionDefinition?

A CompositionDefinition is a Krateo Custom Resource that automates two key tasks:
1. Generates a Custom Resource Definition based on the Helm chart's `values.schema.json` file
2. Creates a Deployment that monitors for new Custom Resources representing the Helm Chart's `values.yaml`