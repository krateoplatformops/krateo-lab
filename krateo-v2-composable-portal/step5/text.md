## Let's find out how to play with the Kubernetes RBAC.

Let's add the proper Roles and ClusterRoles to the `devs` group:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devs-get-list-any-widget-in-fireworksapp-namespace
  namespace: fireworksapp
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
  namespace: fireworksapp-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: devs-get-list-any-widget-in-demosystem-namespace
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devs-create-formtemplates-in-demosystem-namespace
  namespace: fireworksapp-system
rules:
- apiGroups:
  - composition.krateo.io
  resources:
  - fireworksapps
  verbs:
  - create
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devs-create-formtemplates-in-demosystem-namespace
  namespace: fireworksapp-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: devs-create-formtemplates-in-demosystem-namespace
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devs-get-list-any-compositiondefinitions-in-demosystem-namespace
  namespace: fireworksapp-system
rules:
- apiGroups:
  - core.krateo.io
  resources:
  - compositiondefinitions
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devs-get-list-any-compositiondefinitions-in-demosystem-namespace
  namespace: fireworksapp-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: devs-get-list-any-compositiondefinitions-in-demosystem-namespace
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
  namespace: fireworksapp-system
rules:
- apiGroups:
  - ''
  resources:
  - secrets
  - configmaps
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
  namespace: fireworksapp-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: devs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: devs-get-list-create-any-compositions-in-cluster
rules:
- apiGroups:
  - composition.krateo.io
  resources:
  - '*'
  verbs:
  - get
  - list
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devs-get-list-create-any-compositions-in-cluster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: devs-get-list-create-any-compositions-in-cluster
subjects:
- kind: Group
  name: devs
  apiGroup: rbac.authorization.k8s.io
EOF
```{{exec}}

Let's try again to read the `Form` `template-fireworksapp-form` as `cyberjoker` user.

```plain
kubectl get form template-fireworksapp-form --namespace fireworksapp-system -o yaml --kubeconfig cyberjoker.kubeconfig
```{{exec}}

Now `cyberjoker` is able to get the `Form` `template-fireworksapp-form`.
