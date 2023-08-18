
Now we're getting serious! Let's install a `Composition`

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: composition.krateo.io/v0-2-0
kind: DummyChart
metadata:
  name: sample
  namespace: krateo-system
spec:
  data:
    greeting: "Hello World"
    counter: 10
    like: false
EOF
```{{exec}}

Let's wait for the Composition `sample` to be Ready

```plain
kubectl wait dummychart sample --for condition=Ready=True --timeout=60s --namespace krateo-system
```{{exec}}
