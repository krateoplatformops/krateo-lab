# Checking Auto-Reconciliation

To verify the auto-reconciliation behavior of Kubernetes resources, manually delete the repository created in the previous steps from the GitHub portal.

Then, wait for the reconciliation interval of the dynamic controller to trigger the recreation of the repository. You can monitor the controller’s live logs with the following command:

```bash
kubectl logs deploy/gh-repo-controller -n gh-system
```{{exec}}

Wait for the controller to recreate the repository in your GitHub organization. When the process completes, you should see a log message similar to this:

```
2025-06-23T13:32:53Z    DEBUG   rest-dynamic-controller External resource up-to-date    {"op": "Observe", "apiVersion": "github.ogen.krateo.io/v1alpha1", "kind": "Repo", "name": "gh-repo-1", "namespace": "gh-system", "kind": "Repo"}
```

At this point, check your GitHub portal to confirm that the repository has been successfully recreated.

You can also verify the status of the `Repo` resource in Kubernetes:

```bash
kubectl describe repo.github.ogen.krateo.io/gh-repo-1 -n gh-system
```{{exec}}

You should see a successful creation event with a 'x2' in the age, indicating that the controller has successfully reconciled the resource after the deletion.
``` text
Events:
  Type    Reason                   Age                 From  Message
  ----    ------                   ----                ----  -------
  Normal  CreatedExternalResource  11s (x2 over 2m5s)        Successfully requested creation of external resource
```