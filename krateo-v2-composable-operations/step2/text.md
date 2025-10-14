# Deploying the Krateo V2 Template Fireworks App

This guide demonstrates how to generate and deploy a Custom Resource Definition (CRD) representing a `Composition` that contains the "Krateo V2 Template Fireworks app" Helm Chart using a `CompositionDefinition`. While there are three possible installation methods (tgz archive, OCI artifact, or Helm repo), this guide focuses on installing the chart from a Helm repository.

## Prerequisites

As described in the [chart's README](https://github.com/krateoplatformops-blueprints/github-scaffolding/blob/main/README.md), you need to install the toolchain in the `krateo-system` namespace.

## Step 1: Install Required Components

First, add and update the necessary Helm repositories, then install the required providers:

```bash
# Add and update Krateo repository
helm repo add marketplace https://marketplace.krateo.io
helm repo update marketplace
helm install github-provider-kog-repo marketplace/github-provider-kog-repo --namespace krateo-system --create-namespace --wait --version 1.0.0
helm install git-provider krateo/git-provider --namespace krateo-system --create-namespace --wait --version 0.10.1
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm install argocd argo/argo-cd --namespace krateo-system --create-namespace --wait --version 8.0.17
```{{exec}}

In this guide, we skip the argo-cd configuration steps, as it does not properly works in the Killercoda environment.

## Step 2: Apply the CompositionDefinition Manifest

Create the `ghscaffolding-system` namespace:

```bash
kubectl create namespace ghscaffolding-system
```{{exec}}

Apply the `CompositionDefinition` manifest that installs version 2.0.2 of the chart in the `ghscaffolding-system` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: CompositionDefinition
metadata:
  name: github-scaffolding
  namespace: ghscaffolding-system
spec:
  chart:
    repo: github-scaffolding
    url: https://marketplace.krateo.io
    version: 1.0.0
EOF
```{{exec}}


## Step 3: Verify the Installation

1. Wait for the CompositionDefinition to be ready:
```bash
kubectl wait compositiondefinition github-scaffolding --for condition=Ready=True --timeout=600s --namespace ghscaffolding-system
```{{exec}}

2. Check the CompositionDefinition outputs:
```bash
kubectl get compositiondefinition github-scaffolding --namespace ghscaffolding-system -o yaml
```{{exec}}

## What Was Created?

The `core-provider` has generated two main components:

1. A Custom Resource Definition based on the values.json.schema file from the Helm chart:
```bash
kubectl get crd githubscaffoldings.composition.krateo.io -o yaml
```{{exec}}

2. A specific Deployment that uses the `composition-dynamic-controller` image. This deployment watches for new Custom Resources related to the generated CRD and the specific version:
```bash
kubectl get deployment githubscaffoldings-v1-0-0-controller --namespace ghscaffolding-system
```{{exec}}