# Getting Started

1. **Prepare OAS Definition:** Begin by creating or obtaining an OpenAPI Specification (OAS) 3.0+ file that describes the API and resources you intend to manage within Kubernetes. In this guide, we'll focus on two objectives:
- Generate a controller and Custom Resource Definition (CRD) to manage a resource of type `Repoes` on GitHub.
- Enable various operations (observe, create, update, delete) on this resource.

The first step is to locate the OAS Specification file that defines the APIs for GitHub Repository resources. You can find the GitHub Repository OAS 3 Specification [here](https://github.com/krateoplatformops/github-oas3/blob/3-add-repo/repo.yaml).

1. **Inspect the RestDefinition Manifest:**

```bash
cat /root/filesystem/repo-def.yaml
```{{exec}}

2. Create the `gh-system` namespace:

```bash
kubectl create namespace gh-system
```{{exec}}

3. **Apply the RestDefinition Manifest:**

```bash
kubectl apply -f /root/filesystem/repo-def.yaml
```{{exec}}

4. **Wait for the RestDefinition to meet the `Ready:True` condition:**

```bash
kubectl wait restdefinitions gh-repo --for condition=Ready=True --namespace gh-system --timeout=300s
```{{exec}}