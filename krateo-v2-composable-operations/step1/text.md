# Krateo Core Provider

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

## Verify Krateo PlatformOps Installation

Check out for Krateo PlatformOps to become available:
```bash
kubectl wait krateoplatformops krateo --for condition=Ready=True --timeout=600s --namespace krateo-system
```{{exec}}