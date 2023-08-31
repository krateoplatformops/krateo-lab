
What happens when we delete the `Definition` `sample-archive`? We have a Kubernetes Deployment related to the generated CRD and we have a Custom Resource `sample`.

```plain
kubectl delete definition sample-archive --namespace krateo-system
```{{exec}}

The `core-provider` has just deleted:
* the Custom Resource Definition `jenkins.composition.krateo.io`:

```plain
kubectl get crd postgresql.composition.krateo.io
```{{exec}}

* the specific Deployment from the `composition-dynamic-controller`:

```plain
kubectl get deployment postgresqls-v12-8-3-controller --namespace krateo-system
```{{exec}}

* the Custom Resource `sample`:

```plain
kubectl get postgresql sample --namespace krateo-system
```{{exec}}
