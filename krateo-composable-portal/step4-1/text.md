## Let's find out how to play with the Kubernetes RBAC.

```plain
export KUBECONFIG=/root/.kube/config
kubectl apply -f /root/filesystem/cardtemplate-sample2.yaml
kubectl apply -f /root/filesystem/role-2.yaml
```{{exec}}

Now we have two CardTemplates, card-dev-1 and card-dev-2 in the dev-system namespace.

```plain
kubectl get cardtemplates -n dev-system
```{{exec}}

What we did previously was to restrict the permissions for the 'cyberjoker' user, letting only the ability to 'get' only the CardTemplate card-dev-1 and nothing else.

```plain
- apiGroups:
  - widgets.ui.krateo.io
  resources:
  - cardtemplates
  resourceNames:
  - card-dev-1
  verbs:
  - 'get'
```

Let's check which CardTemplates the 'cyberjoker' is able to 'list':
```plain
export KUBECONFIG=/root/cyberjoker.kubeconfig
kubectl get cardtemplates -n dev-system
```{{exec}}

But 'cyberjoker' is able to 'get' the CardTemplate card-dev-1:
```plain
kubectl get cardtemplates card-dev-1 -n dev-system -o json | jq
```{{exec}}
