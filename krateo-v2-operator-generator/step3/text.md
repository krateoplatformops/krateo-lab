## Verifying CRD and Controller Deployment
At this point, you should notice that a CRD has been created based on the OpenAPI Specification provided in the RestDefinition Manifest.

## Verify the Creation of the CRDs

- **Check the CRD for repository information:**

  ```bash
  kubectl get crds repoes.gen.github.com
  ```{{exec}}

- **Check the CRD for centralized authentication information:**

  ```bash
  kubectl get crds bearerauths.gen.github.com
  ```{{exec}}

The first CRD (`repoes.gen.github.com`) defines the schema for information about the repository you want to create on GitHub. The second CRD (`bearerauths.gen.github.com`) provides a centralized reference for authentication information for GitHub (specifically for any resource within the `gen.github.com` group).

## Check for Deployed Resources

To verify the deployment of the controller managing these resources, run:

```bash
kubectl get deployments --namespace gh-system
```{{exec}}

This deployment runs a Pod containing a dynamic controller that manages custom resources (CRs) of type `repoes.gen.github.com`, handling necessary actions to manage the lifecycle of the resource.