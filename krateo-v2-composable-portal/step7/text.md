## Check Form

Let's check the status of the `CustomForm` `template-fireworksapp-customform` resource:

```plain
kubectl get widget template-fireworksapp-card --namespace krateo-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns the CustomForm and the relative schema. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Let's check the status in detail:

```plain
kubectl get widget template-fireworksapp-card --namespace krateo-system -o yaml --kubeconfig admin.kubeconfig -o yaml
```{{exec}}

The status returns the JSON schema referenced by the API.