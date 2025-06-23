# Getting Started

This guide provides a step-by-step approach to generating a provider for managing GitHub repositories using the Krateo Operator Generator (KOG). It assumes you have a basic understanding of Kubernetes and OpenAPI specifications.

## Step 1: Prepare Your OpenAPI Specification

1. **Obtain or generate** the OAS for your target API
   - Example: GitHub API OAS available at [GitHub's REST API description](https://github.com/github/rest-api-description/blob/main/descriptions/ghes-3.9/ghes-3.9.yaml)
   
2. **Scope your OAS** to only include necessary endpoints:
   - Recommended for large APIs to reduce complexity
   - Create separate files for different resource types (e.g., `repositories.yaml`, `teamrepo.yaml`)

3. **Add authentication** information if missing from original OAS: (notes that components is a "root" element in OAS 3+)
```diff
openapi: 3.0.3
servers:
  - url: https://api.github.com
paths:
  ...
components:
+ securitySchemes:
+   oauth:
+     type: http
+   scheme: bearer
```

This step has already been completed for you, and the OAS definition file is available at `/root/filesystem/repo.yaml`.

## Step 2: Prepare Kubernetes Environment

1. **Create a namespace where we will deploy the RestDefinition:**

```bash
kubectl create namespace gh-system
```{{exec}}

2. **Inspect the OAS Definition:**
Review the OAS definition file to understand the structure and operations available for the `Repoes` resource. This file will be used to generate the necessary CRD and controller.

```bash
cat /root/filesystem/repo.yaml
```{{exec}}

3. **Create the configmap to store the OAS definition:**

```bash
kubectl create configmap repo --from-file=/root/filesystem/repo.yaml -n gh-system
```{{exec}}

## Step 3: Create RestDefinition for GitHub Repositories

1. **Create a `RestDefinition` resource**
In order to create a RestDefinition for GitHub repositories, you need to define the resource group, resource kind, and the verbs that the controller will support. The `oasPath` should point to the ConfigMap containing your OAS. You can learn more about the `RestDefinition` resource [here](README.md#restdefinition-specifications).

```bash
cat <<EOF | kubectl apply -f -
apiVersion: swaggergen.krateo.io/v1alpha1
kind: RestDefinition
metadata:
  name: gh-repo
  namespace: gh-system
spec:
  oasPath: configmap://gh-system/repo/repo.yaml
  resourceGroup: github.kog.krateo.io
  resource: 
    kind: Repo
    identifiers:
      - id 
      - name
      - html_url
    verbsDescription:
    - action: create
      method: POST
      path: /orgs/{org}/repos
    - action: delete
      method: DELETE
      path: /repos/{org}/{name}
    - action: get
      method: GET
      path: /repos/{org}/{name}
    - action: update
      method: PATCH
      path: /repos/{org}/{name}
EOF
```{{exec}}

2. **Wait for the CRD and Controller to be Created**
```bash
kubectl wait restdefinition gh-repo --for condition=Ready=True --namespace gh-system --timeout=600s
```{{exec}}
