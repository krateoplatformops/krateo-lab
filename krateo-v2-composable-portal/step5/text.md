## Add Krateo CardTemplate to retrieve the FormTemplate

```plain
cat <<EOF | kubectl apply -f -
apiVersion: widgets.krateo.io/v1alpha1
kind: CardTemplate
metadata:
  name: fireworksapp-tgz
  namespace: demo-system
spec:
  app:
    icon: fa-solid fa-truck-fast
    color: green
    title: Fireworksapp Template
    content: This template creates an instance of Fireworksapp composition
  formTemplateRef:
    name: fireworksapp-tgz
    namespace: demo-system
EOF
```{{exec}}

Let's check the status of the `CardTemplate` `fireworksapp-tgz` resource:

```plain
kubectl get cardtemplate fireworksapp-tgz --namespace demo-system -o yaml
```{{exec}}

The status returns the possible actions available for the user requesting the cardtemplate. In Krateo, the Kubernetes RBAC is evaluated to populate the actions array.

Focus on the `actions` array.

What happens when we try to retrieve the `FormTemplate` as `cyberjoker` user?

```plain
kubectl get cardtemplate fireworksapp-tgz --namespace demo-system -o yaml --kubeconfig cyberjoker.kubeconfig
```{{exec}}

Focus again on the `actions` array.
