## Install Krateo Composable Portal widgets
Now we start to interact with Composable Portal widgets. Let's start with a CardTemplate:

```plain
export KUBECONFIG=/root/.kube/config
kubectl apply -f /root/filesystem/cardtemplate-sample1.yaml
```{{exec}}

Let's switch back to the 'cyberjoker' user:

```plain
export KUBECONFIG=/root/cyberjoker.kubeconfig
```{{exec}}

With the current Role and RoleBinding, the 'cyberjoker' user can do anything on any CardTemplate in the dev-system namespace:
```plain
kubectl get cardtemplates -n dev-system
```{{exec}}

Let's check in details what info contains the CardTemplate card-dev-1:
```plain
kubectl get cardtemplates card-dev-1 -n dev-system -o json | jq
```{{exec}}

What if we want the krateo-bff to substitute the placeholder values?

```plain
kubectl get --raw "/apis/widgets.ui.krateo.io/v1alpha1/namespaces/dev-system/cardtemplates/card-dev-1?eval=true" | jq
```{{exec}}
