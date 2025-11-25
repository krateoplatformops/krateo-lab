## Check Form

Let's check the status of the `Form` `github-scaffolding-with-composition-page-form` resource:

```plain
kubectl get form github-scaffolding-with-composition-page-form --namespace demo-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns the Form and the relative schema. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.