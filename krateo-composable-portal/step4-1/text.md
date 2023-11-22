## Install Krateo Composable Portal authn-service Helm chart
Let's find out how to play with the Kubernetes RBAC.

```plain
export KUBECONFIG=/root/.kube/config
kubectl apply -f /root/filesystem/cardtemplate-sample2.yaml
kubectl apply -f /root/filesystem/role2.yaml
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

Let's check if it's right - let's regenerate the kubeconfig for 'cyberjoker':
```plain
cd && curl http://localhost:30007/basic/login -H "Authorization: Basic Y3liZXJqb2tlcjoxMjM0NTY=" | jq -r .data > cyberjoker.kubeconfig
```{{exec}}

Let's check which CardTemplates the 'cyberjoker' is able to 'list':
```plain
export KUBECONFIG=/root/cyberjoker.kubeconfig
kubectl get cardtemplates -n dev-system
```{{exec}}
