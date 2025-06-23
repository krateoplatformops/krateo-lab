# Extended Example: External API that requires a plugin to handle external API calls

This example demonstrates how to create a Krateo provider for managing GitHub repositories using an external web service to handle API calls. This approach is useful when the API isn't directly compatible with Kubernetes resource management or requires additional processing.

For an API to be compatible with Kubernetes resource management, it should create, update, and delete resources in a way that is similar to Kubernetes resources. This means the API should support the same operations as Kubernetes resources, such as create, update, delete, and get. If the API doesn't support these operations or requires additional processing, you can use an external web service to handle the API calls.

This example assumes you have a basic understanding of Kubernetes, OpenAPI specifications, and web service development.

**Note:** In this example, we'll develop a web service that handles API calls to the GitHub API. The web service will be responsible for creating, updating, and deleting repositories in GitHub. While this example uses Go, you can use any programming language and framework you're comfortable with.

## Step 1: Prepare Your OpenAPI Specification

1. **Obtain or generate** the OAS for your target API
   - Example: GitHub API OAS available at [GitHub's REST API description](https://github.com/github/rest-api-description/blob/main/descriptions/ghes-3.9/ghes-3.9.yaml)
   
2. **Scope your OAS** to only include necessary endpoints:
   - Recommended for large APIs to reduce complexity
   - Create separate files for different resource types (e.g., `repositories.yaml`, `teamrepo.yaml`)
  
3. **Add authentication** information if missing from the original OAS:
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

## Step 2: Prepare Kubernetes Environment

1. **Create a namespace where we will deploy the RestDefinition:**

```bash
kubectl create namespace gh-system
```{{exec}}

You can skip this step if you have already created the namespace in a previous steps.

2. **Inspect the OAS Definition:**
Review the OAS definition file to understand the structure and operations available for the `Repoes` resource. This file will be used to generate the necessary CRD and controller.

```bash
cat /root/filesystem/teamrepo_no_ws.yaml
```{{exec}}

3. **Create the configmap to store the OAS definition:**

```bash
kubectl create configmap teamrepo --from-file=/root/filesystem/teamrepo_no_ws.yaml -n gh-system
```{{exec}}

### Step 3: Create RestDefinition for GitHub TeamRepos

1. **Create a `RestDefinition` resource**
In order to create a RestDefinition for GitHub teamrepos, you need to define the resource group, resource kind, and the verbs that the controller will support. The `oasPath` should point to the ConfigMap containing your OAS. You can learn more about the `RestDefinition` resource [here](README.md#restdefinition-specifications).

```bash
cat <<EOF | kubectl apply -f -
apiVersion: swaggergen.krateo.io/v1alpha1
kind: RestDefinition
metadata:
  name: gh-teamrepo
  namespace: gh-system
spec:
  oasPath: configmap://gh-system/teamrepo/teamrepo_no_ws.yaml
  resourceGroup: github.kog.krateo.io
  resource: 
    kind: TeamRepo
    identifiers:
      - id 
      - name
      - full_name
      - permission
    verbsDescription:
    - action: create
      method: PUT
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: delete
      method: DELETE
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: get
      method: GET
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
    - action: update
      method: PUT
      path: /orgs/{org}/teams/{team_slug}/repos/{owner}/{repo}
EOF
```{{exec}}

2. **Wait for the CRD and Controller to be Created**

```bash
kubectl wait restdefinition gh-teamrepo --for condition=Ready=True --namespace gh-system --timeout=600s
```{{exec}}