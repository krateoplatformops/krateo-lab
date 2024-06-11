## Let's find out how to play with the Kubernetes RBAC.

Let's add the Role to the `devs` group to `get` and `list` any widget within the `demo-system` namespace:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devs-get-list-any-widget-in-demosystem-namespace
  namespace: demo-system
rules:
- apiGroups:
  - widgets.krateo.io
  resources:
  - '*'
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devs-get-list-any-widget-in-demosystem-namespace
  namespace: demo-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: devs-get-list-any-widget-in-demosystem-namespace
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
EOF
```{{exec}}

Let's try again to read the `FormTemplate` `fireworksapp-tgz` as `cyberjoker` user.

```plain
kubectl get formtemplate fireworksapp-tgz --namespace demo-system -o yaml --kubeconfig cyberjoker.kubeconfig
```{{exec}}

Now `cyberjoker` is able to get the `FormTemplate` `fireworksapp-tgz` but has no permission to create the related composition.
