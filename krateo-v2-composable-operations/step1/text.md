# Install Krateo
To install Krateo, we will follow the [official Krateo Documentation](https://docs.krateo.io/how-to-guides/install-krateo/installing-krateo-kind).

```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo

helm upgrade installer-crd installer-crd \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.6.0 \
  --wait

helm upgrade installer installer \
  --set krateoplatformops.composablefinops.enabled=false \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.6.0 \
  --wait
```{{exec}}

Wait for Krateo to be ready:
```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
```{{exec}}
This step might take upwards of 10 minutes, go grab a coffee in the meantime or learn more about `core-provider`!

# Learn about Krateo Core Provider

## Krateo Core Provider

The Krateo Core Provider is the foundational component of Krateo Composable Operations (KCO), enabling the management of Helm charts as Kubernetes-native resources. It provides:

- Schema validation through JSON Schema
- Automated CRD generation
- Versioned composition management
- Secure authentication mechanisms

## Glossary

- **CRD (Custom Resource Definition):** A Kubernetes resource that defines custom objects and their schemas, enabling users to extend Kubernetes functionality.
- **CompositionDefinition:** A custom resource in the `core-provider` that defines how Helm charts are managed and deployed in Kubernetes.
- **CDC (Composition Dynamic Controller):** A controller deployed by the `core-provider` to manage resources defined by a `CompositionDefinition`. This controller is responsible to create, update, and delete helm releases and their associated resources based on the values defined in the `composition`
- **Helm Chart:** A package of pre-configured Kubernetes resources used to deploy applications.
- **OCI Registry:** A container registry that supports the Open Container Initiative (OCI) image format, used for storing and distributing Helm charts.
- **RBAC Policy:** A set of rules that define permissions for accessing Kubernetes resources. Typically composed of roles, role bindings, cluster roles, and cluster role bindings assigned to service accounts.
- **values.schema.json:** A JSON Schema file included in Helm charts to define and validate the structure of `values.yaml`.

## CompositionDefinition specifications and examples

The `core-provider` is a Kubernetes operator that downloads and manages Helm charts. It checks for the existence of `values.schema.json` and uses it to generate a Custom Resource Definition (CRD) in Kubernetes, accurately representing the possible values that can be expressed for the installation of the chart.

Kubernetes is designed to validate resource inputs before applying them to the cluster, and the `core-provider` provides input validation to ensure that incorrect inputs are not accepted.

Learn more about the `core-provider` in the [official documentation](https://github.com/krateoplatformops/core-provider/blob/main/README.md)