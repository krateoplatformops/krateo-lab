# Delete the Repo CR

To delete the repository, you can delete the `Repo` custom resource:

```bash
kubectl delete repo.github.kog.krateo.io gh-repo-1 -n gh-system
```

This will trigger the controller to delete the corresponding repository in GitHub.
You should see an event for the Repo resource indicating that the external resource was deleted successfully:

You can check the status of the deletion by running:

```bash
kubectl get events --sort-by='.lastTimestamp' -n gh-system | grep repo/gh-repo-1
```

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   DeletedExternalResource      repo/gh-repo-1        Successfully requested deletion of external resource
```