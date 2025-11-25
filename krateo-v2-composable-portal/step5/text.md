## Let's find out how to play with the Kubernetes RBAC.

Let's add the proper Roles and ClusterRoles to the `labs` group:

```plain
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: labs-get-list-any-widget-in-demosystem-namespace
  namespace: demo-system
rules:
- apiGroups:
  - templates.krateo.io
  resources:
  - '*'
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: labs-get-list-any-widget-in-demosystem-namespace
  namespace: demo-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: labs-get-list-any-widget-in-demosystem-namespace
subjects:
- kind: Group
  name: labs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: labs-create-compositions-in-demosystem-namespace
  namespace: demo-system
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
  name: labs-create-compositions-in-demosystem-namespace
  namespace: demo-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: labs-create-compositions-in-demosystem-namespace
subjects:
- kind: Group
  name: labs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: labs-get-list-any-compositiondefinitions-in-demosystem-namespace
  namespace: demo-system
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
  name: labs-get-list-any-compositiondefinitions-in-demosystem-namespace
  namespace: demo-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: labs-get-list-any-compositiondefinitions-in-demosystem-namespace
subjects:
- kind: Group
  name: labs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: labs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
  namespace: demo-system
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
  name: labs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
  namespace: demo-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: labs-get-list-any-secrets-and-configmaps-in-demosystem-namespace
subjects:
- kind: Group
  name: labs
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: labs-get-list-create-any-compositions-in-cluster
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
  name: labs-get-list-create-any-compositions-in-cluster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: labs-get-list-create-any-compositions-in-cluster
subjects:
- kind: Group
  name: labs
  apiGroup: rbac.authorization.k8s.io
EOF
```{{exec}}