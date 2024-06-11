
What happens when we delete the `CompositionDefinition` `fireworksapp-tgz`? We have a Kubernetes Deployment related to the generated CRD and we have a Custom Resource `fireworksapp-tgz`.

```plain
kubectl delete compositiondefinition fireworksapp-tgz --namespace krateo-system
```{{exec}}

The `core-provider` has just deleted:
* the Custom Resource Definition `fireworksapp.composition.krateo.io`:

```plain
kubectl get crd fireworksapps.composition.krateo.io
```{{exec}}

* the specific Deployment from the `composition-dynamic-controller`:

```plain
kubectl get deployment fireworksapps-v0-1-0-controller --namespace krateo-system
```{{exec}}

* the Custom Resource `fireworksapp-tgz`:

```plain
kubectl get fireworksapp fireworksapp-tgz --namespace krateo-system
```{{exec}}
