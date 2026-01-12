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
  --version 2.7.0 \
  --wait

helm upgrade installer installer \
  --set krateoplatformops.composablefinops.enabled=false \
  --repo https://charts.krateo.io \
  --namespace krateo-system \
  --create-namespace \
  --install \
  --version 2.7.0 \
  --wait
```{{exec}}

Wait for Krateo to be ready:
```plain
kubectl wait krateoplatformops krateo --for condition=Ready=True --namespace krateo-system --timeout=660s
```{{exec}}
This step might take upwards of 10 minutes, go grab a coffee in the meantime or learn more about `core-provider`!

# Learn about Krateo Core Provider

# Krateo Core Provider

The Krateo Core Provider is the foundational component of Krateo Composable Operations (KCO), enabling the management of Helm charts as Kubernetes-native resources. It provides:

## Key Features
- **Dynamic CRD Generation**: Automatically creates and manages versioned CRDs from a chart's values.schema.json.
- **Schema-Driven Validation**: Leverages JSON Schema to enforce strict input validation at the API level, preventing invalid configurations before they are applied.
- **Secure Credential Management**: Integrates with Kubernetes secrets for seamless authentication against private OCI and Helm repositories.
- **Isolated RBAC Policies**: Generates and manages fine-grained RBAC policies for each composition, ensuring controllers have the minimum necessary permissions.
- **Multi-Version Chart Support**: Manages multiple versions of a CompositionDefinition concurrently, allowing for smooth, controlled upgrades and rollbacks.

## Glossary

- **CRD (Custom Resource Definition):** A Kubernetes resource that defines custom objects and their schemas, enabling users to extend Kubernetes functionality.
- **CompositionDefinition:** A CompositionDefinition is a declarative Krateo resource that serves as a master blueprint for a deployable service. It consumes a standard Helm chart as input and uses it to dynamically generate a new, high-level Custom Resource Definition (CRD) in Kubernetes. This process effectively registers the application as a new API within the cluster. It abstracts underlying Helm complexity, establishing a standardized and reusable template for creating application instances.
- **Composition:** A Composition is a Custom Resource representing a single, live instance of a service defined by a CompositionDefinition. Its CRD is generated from the `values.schema.json` file of the Helm chart associated with the CompositionDefinition. The creation of a Composition resource triggers the installation of the associated Helm chart. Its spec field allows for per-instance configuration overrides, enabling customized deployments from a single, authoritative blueprint.
- **CDC (Composition Dynamic Controller):** A dedicated controller deployed by the Core Provider for each CompositionDefinition. The CDC is responsible for managing the lifecycle (create, update, delete) of Helm releases based on Composition resources.
- **Helm Chart:** A package of pre-configured Kubernetes resources used to deploy applications.
- **OCI Registry:** A container registry that supports the Open Container Initiative (OCI) image format, used for storing and distributing Helm charts.
- **RBAC Policy:** A set of rules that define permissions for accessing Kubernetes resources. Typically composed of roles, role bindings, cluster roles, and cluster role bindings assigned to service accounts.
- **values.schema.json:** A JSON Schema file included in Helm charts to define and validate the structure of `values.yaml`.


## CompositionDefinition specifications and examples

The `core-provider` is a Kubernetes operator that downloads and manages Helm charts. It checks for the existence of `values.schema.json` and uses it to generate a Custom Resource Definition (CRD) in Kubernetes, accurately representing the possible values that can be expressed for the installation of the chart.

Kubernetes is designed to validate resource inputs before applying them to the cluster, and the `core-provider` provides input validation to ensure that incorrect inputs are not accepted.

Learn more about the `core-provider` in the [official documentation](https://docs.krateo.io/key-concepts/kco/core-provider)