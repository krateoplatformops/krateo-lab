## Check Panel to retrieve the Form

Let's check the status of the `Panel` `github-scaffolding-with-composition-page-panel` resource:

```plain
kubectl get panel github-scaffolding-with-composition-page-panel --namespace demo-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns the possible actions available for the user requesting the `Panel`. In Krateo, the Kubernetes RBAC is evaluated to populate the resourcesRefs array.

Focus on the `status.resourcesRefs` array.

What happens when we try to retrieve the `Panel` as `cyberjoker` user?

```plain
kubectl get panel github-scaffolding-with-composition-page-panel --namespace demo-system -o yaml --kubeconfig cyberjoker.kubeconfig
```{{exec}}

Focus again on the `status.resourcesRefs` array.
