# Patch the Repo CR

To update the repository, you can patch the `Repo` custom resource. For example, to change the description of the repository:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: github.ogen.krateo.io/v1alpha1
kind: Repo
metadata:
  name: gh-repo-1
  namespace: gh-system
spec:
  configurationRef:
    name: my-repo-config
    namespace: default 
  org: krateoplatformops-test
  name: krateo-test-repo
  description: A new description of the repository set by Krateo
  visibility: public
  has_issues: true
EOF
```{{exec}}
This will trigger the controller to update the repository in GitHub with the new description.

```bash
kubectl describe repo.github.kog.krateo.io/gh-repo-1 -n gh-system
```{{exec}}

You should see an event for the Repo resource indicating that the external resource was updated successfully:

```text
Events:
  Type     Reason                         Age                  From  Message
  ----     ------                         ----                 ----  -------
  Normal   UpdatedExternalResource        10s                       Successfully requested update of external resource
```
