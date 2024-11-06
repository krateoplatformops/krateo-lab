## Check Template Column and Row

Let's check the status of the `Column` `templates-row-column-1` resource:

```plain
kubectl get collection templates-row-column-1 --namespace fireworksapp-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns all the cardtemplate referenced by the column. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Let's check the status of the `Row` `templates-row` resource:

```plain
kubectl get collection templates-row --namespace fireworksapp-system -o yaml --kubeconfig admin.kubeconfig
```{{exec}}

The status returns all the columns referenced by the row. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.
