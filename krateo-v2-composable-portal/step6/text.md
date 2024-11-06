## Check Card to retrieve the Form

Let's check the status of the `Card` `template-fireworksapp-card` resource:

```plain
kubectl get widget template-fireworksapp-card --namespace fireworksapp-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns the possible actions available for the user requesting the cardtemplate. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Focus on the `actions` array.

What happens when we try to retrieve the `Card` as `cyberjoker` user?

```plain
kubectl get widget template-fireworksapp-card --namespace fireworksapp-system -o yaml --kubeconfig cyberjoker.kubeconfig
```{{exec}}

Focus again on the `actions` array.
