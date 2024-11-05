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

# Install GitHub and Git providers
helm install github-provider krateo/github-provider --namespace krateo-system --create-namespace
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace

# Add and update Argo repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

# Install ArgoCD
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait
```{{exec}}

## Step 2: Apply the CompositionDefinition Manifest

Apply the `CompositionDefinition` manifest that installs version 1.1.5 of the chart in the `krateo-system` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  annotations:
    krateo.io/connector-verbose: "true"
  name: fireworksapp-1-1-5
  namespace: fireworksapp-system
spec:
  chart:
    repo: fireworks-app
    url: https://charts.krateo.io
    version: 1.1.5
EOF
```{{exec}}


## Step 3: Verify the Installation

1. Wait for the CompositionDefinition to be ready:
```bash
kubectl wait compositiondefinition fireworksapp-1-1-5 --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

2. Check the CompositionDefinition outputs (pay attention to the `RESOURCE` field):
```bash
kubectl get compositiondefinition fireworksapp-1-1-5 --namespace krateo-system
```{{exec}}

## What Was Created?

The `core-provider` has generated two main components:

1. A Custom Resource Definition based on the values.json.schema file from the Helm chart:
```bash
kubectl get crd fireworksapps.composition.krateo.io -o yaml
```{{exec}}

2. A specific Deployment that uses the `composition-dynamic-controller` image. This deployment watches for new Custom Resources related to the generated CRD and the specific version:
```bash
kubectl get deployment fireworksapps-v1-1-5-controller --namespace krateo-system
```{{exec}}