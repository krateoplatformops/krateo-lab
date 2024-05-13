
Now we're getting serious! Let's install a `Composition` leveraging the `sample-archive` CompositionDefinition.

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: composition.krateo.io/v12-8-3
kind: Postgresql
metadata:
  name: sample
  namespace: krateo-system
spec:
  architecture: standalone
EOF
```{{exec}}

Let's wait for the Composition `sample` to be Ready

```plain
kubectl wait postgresql sample --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Composition `sample` outputs

```plain
kubectl get postgresql sample --namespace krateo-system
```{{exec}}
