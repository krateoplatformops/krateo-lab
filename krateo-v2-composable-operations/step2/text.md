# Deploying the Krateo V2 Template Github Scaffolding Blueprint as a Composition

This guide demonstrates how to generate and deploy a Custom Resource Definition (CRD) representing a `Composition` that contains the "Krateo V2 Template Github Scaffolding Blueprint" Helm Chart using a `CompositionDefinition`. While there are three possible installation methods (tgz archive, OCI artifact, or Helm repo), this guide focuses on installing the chart from a Helm repository.

## Step 1: Apply the CompositionDefinition Manifest

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