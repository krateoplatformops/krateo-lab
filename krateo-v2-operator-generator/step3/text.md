## Verifying CRD and Controller Deployment
At this point, you should notice that a CRD has been created based on the OpenAPI Specification provided in the RestDefinition Manifest.

1. **Verify the CRD creation**
```bash
kubectl get crds | grep github.kog.krateo.io 
```{{exec}}

You should see:
```text
bearerauths.github.kog.krateo.io           2025-06-13T08:28:06Z
repoes.github.kog.krateo.io                2025-06-13T08:28:06Z
```

If you see `bearerauths` and `repoes`, the CRDs have been created successfully. The second CRD represents the `repo` object. The first one is the `bearerauth` object, which is used to authenticate requests to the GitHub API.

2. **Verify the Controller is Running**
```bash
kubectl get deploy -n gh-system
```{{exec}}

You should see a deployment named `gh-repo-controller`, which is responsible for managing the `Repo` resources.

If you see the deployment, you can check the logs of the controller pod to see if it is running correctly:
```bash
kubectl logs deploy/gh-repo-controller -n gh-system
```{{exec}}

At this point you have a running operator able to handle GitHub repositories. You can create, update, and delete repositories using the custom resource.