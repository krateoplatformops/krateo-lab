# Checking Auto-Reconciliation

To verify the auto-reconciliation behavior of Kubernetes resources, manually delete the repository created in the previous steps from the GitHub portal.

Then, wait for the reconciliation interval of the dynamic controller to trigger the recreation of the repository. You can monitor the controller’s live logs with the following command:

```bash
kubectl logs -f --namespace gh-system deployments/repoes-v1alpha1-controller
```{{exec}}

Wait for the controller to recreate the repository in your GitHub organization. When the process completes, you should see a log message similar to this:

```
{"level":"debug","service":"composition-dynamic-controller","op":"Observe","apiVersion":"gen.github.com/v1alpha1","kind":"Repo","name":"gh-repo1","namespace":"gh-system","Resource":"Repo","time":"2024-11-06T15:52:50Z","message":"External resource up-to-date."}
```

At this point, check your GitHub portal to confirm that the repository has been successfully recreated.