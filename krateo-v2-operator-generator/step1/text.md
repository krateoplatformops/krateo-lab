# oasgen-provider
A k8s controller that generates CRDs and controller to manage resources from OpenAPI Specification (OAS) 3.1 (also 3.0 is supported).

## Core Features
- **CRD Generation**: Automatically generates CRDs from OAS 3.1 definitions. This allows users to define custom resources that match the schema described in their API specifications, enabling seamless integration and management within Kubernetes environments.
- **Controller Generation**: Beyond CRDs, oasgen-provider also automates the creation of controllers. Controllers are essential components in Kubernetes that watch for changes in resource states and act accordingly to maintain desired states. By generating controllers from OAS definitions, oasgen-provider facilitates the management of custom resources according to the logic defined in the API specifications.
- **Custom Resource Management**: With the generated CRDs and controllers, users can manage custom resources directly within Kubernetes. This includes creating, updating, deleting, and monitoring the state of these resources, all aligned with the definitions provided in the OAS 3.1 specification.

## Benefits
- **Streamlined Development:** Reduces manual coding efforts, streamlining the development process for Kubernetes-native applications.
- **Enhanced Flexibility:** Enables easy adaptation of Kubernetes resources to match evolving API specifications.
- **Improved Integration:** Facilitates better integration between Kubernetes and external services or applications.

## Technical Overview

`oasgen-provider` analyzes OAS 3.1 definitions to discern the structure and requirements of the intended resources. Utilizing this information, it orchestrates the deployment of the [rest-dynamic-controller](https://github.com/krateoplatformops/rest-dynamic-controller), specifically tasked with managing resources that correspond to the type defined by the CRD.


# Operator Generator installation

```bash
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install krateo-oasgen-provider krateo/oasgen-provider --version 0.4.2 --namespace krateo-system --create-namespace 
```{{exec}}

Wait for the generator to be available:

```bash
kubectl wait deployments krateo-oasgen-provider --for condition=Available=True --namespace krateo-system --timeout=300s
```{{exec}}

# Install Snowplow for handling K8s plurals

```
helm install snowplow krateo/snowplow --version 0.4.3 -n krateo-system  --create-namespace 
```{{exec}}

Wait for the Snowplow to be available:

```bash
kubectl wait deployments snowplow --for condition=Available=True --namespace krateo-system --timeout=300s
```{{exec}}

Create the `gh-system` namespace:

```bash
kubectl create namespace gh-system
```{{exec}}