## Verifying CRD and Controller Deployment
At this point, you should notice that a CRD has been created based on the OpenAPI Specification provided in the RestDefinition Manifest.

1. **Check CRD creation:**
   ```bash
   kubectl get crds | grep github.ogen.krateo.io 
   ```{{exec}}

   You should see:
   ```text
   repoconfigurations.github.ogen.krateo.io           2025-06-13T08:28:06Z
   teamrepos.github.ogen.krateo.io             2025-06-13T08:28:06Z
   ```

   If you see `repoconfigurations` and `teamrepos`, the CRDs are created successfully. The second CRD represents the `teamrepo` object, while the first one is the `repoconfiguration` object used to authenticate requests to the GitHub API.

   **Note:** If you've previously created the `repo` RestDefinition, you'll also see the `repoes.github.ogen.krateo.io` CRD. However, the `repoconfigurations.github.ogen.krateo.io` CRD is shared between RestDefinitions because they use the same group and authentication scheme.

2. **Verify controller deployment:**
   ```bash
   kubectl get deploy -n gh-system
   ```{{exec}}
   
   You should see a deployment named `gh-teamrepo-controller` responsible for managing the `teamrepo` resources.
   
   If you see the deployment, check the controller pod logs to verify it's running correctly:
   ```bash
   kubectl logs deploy/gh-teamrepo-controller -n gh-system
   ```{{exec}}

3. **Check RestDefinition status:**
```bash
kubectl get restdefinition -n gh-system
kubectl describe restdefinition gh-teamrepo -n gh-system
```{{exec}}

At this point, you have a running operator capable of handling GitHub teamrepos. You can create, update, and delete teamrepos using the custom resource.