# Patch the Repo CR

To update the repository, you can patch the `Repo` custom resource. For example, to change the description of the repository:

1. Open the Killercoda IDE and navigate to the following file:
```
/root/filesystem/cr/repo-1.yaml
```
1. Modify the file to include a new description and change the organization name to one you have access to.
2. Apply the credentials manifest:
```bash
kubectl apply -f /root/filesystem/cr/repo-1.yaml
```{{exec}}

This will trigger the controller to update the repository in GitHub with the new description.

```bash
kubectl describe repo.github.ogen.krateo.io/gh-repo-1 -n gh-system
```{{exec}}

You should see an event for the Repo resource indicating that the external resource was updated successfully:

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   UpdatedExternalResource        10s                       Successfully requested update of external resource
```
