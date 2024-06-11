## Add Krateo Column and Row to retrieve the CardTemplate

```plain
cat <<EOF | kubectl apply -f -
apiVersion: widgets.krateo.io/v1alpha1
kind: Column
metadata:
  name: fireworksapp-tgz
  namespace: demo-system
spec:
  app:
    props:
      width: "12"
  cardTemplateListRef:
    - name: fireworksapp-tgz
      namespace: demo-system
---
apiVersion: widgets.krateo.io/v1alpha1
kind: Row
metadata:
  name: two
  namespace: demo-system
spec:
  columnListRef:
    - name: fireworksapp-tgz
      namespace: demo-system
EOF
```{{exec}}

Let's check the status of the `Column` `fireworksapp-tgz` resource:

```plain
kubectl get column fireworksapp-tgz --namespace demo-system -o yaml
```{{exec}}

The status returns all the cardtemplate referenced by the column. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Let's check the status of the `Row` `two` resource:

```plain
kubectl get row two --namespace demo-system -o yaml
```{{exec}}

The status returns all the columns referenced by the row. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Let's open again [Krateo Portal]({{TRAFFIC_HOST1_30080}}) and check if there's a new template to fill.
