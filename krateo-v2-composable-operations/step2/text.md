# Deploying the Krateo V2 Template Fireworks App

This guide demonstrates how to generate and deploy a Custom Resource Definition (CRD) representing a `Composition` that contains the "Krateo V2 Template Fireworks app" Helm Chart using a `CompositionDefinition`. While there are three possible installation methods (tgz archive, OCI artifact, or Helm repo), this guide focuses on installing the chart from a Helm repository.

## Prerequisites

As described in the [chart's README](https://github.com/krateoplatformops/krateo-v2-template-fireworksapp/blob/main/README.md), you need to install the toolchain in the `krateo-system` namespace.

## Step 1: Install Required Components

First, add and update the necessary Helm repositories, then install the required providers:

```bash
# Add and update Krateo repository
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install github-provider-kog krateo/github-provider-kog --namespace krateo-system --create-namespace --wait --version 0.0.7
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace --wait --version 0.10.1
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait --version 8.0.17
```{{exec}}

## Step 2: Apply the CompositionDefinition Manifest

Create the `fireworksapp-system` namespace:

```bash
kubectl create namespace fireworksapp-system
```{{exec}}

Apply the `CompositionDefinition` manifest that installs version 2.0.2 of the chart in the `fireworksapp-system` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  annotations:
    krateo.io/connector-verbose: "true"
  name: fireworksapp-cd
  namespace: fireworksapp-system
spec:
  chart:
    repo: fireworks-app
    url: https://charts.krateo.io
    version: 2.0.2
EOF
```{{exec}}


## Step 3: Verify the Installation

1. Wait for the CompositionDefinition to be ready:
```bash
kubectl wait compositiondefinition fireworksapp-cd --for condition=Ready=True --timeout=600s --namespace fireworksapp-system
```{{exec}}

2. Check the CompositionDefinition outputs:
```bash
kubectl get compositiondefinition fireworksapp-cd --namespace fireworksapp-system -o yaml
```{{exec}}

## What Was Created?

The `core-provider` has generated two main components:

1. A Custom Resource Definition based on the values.json.schema file from the Helm chart:
```bash
kubectl get crd fireworksapps.composition.krateo.io -o yaml
```{{exec}}

2. A specific Deployment that uses the `composition-dynamic-controller` image. This deployment watches for new Custom Resources related to the generated CRD and the specific version:
```bash
kubectl get deployment fireworksapps-v2-0-2-controller --namespace fireworksapp-system
```{{exec}}