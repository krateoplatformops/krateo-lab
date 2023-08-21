
Let's install a `Definition`

<br>

```plain
cat <<EOF | kubectl apply -f -
apiVersion: core.krateo.io/v1alpha1
kind: Definition
metadata:
  name: sample
  namespace: krateo-system
spec:
  chartUrl: https://github.com/lucasepe/busybox-chart/releases/download/v0.2.0/dummy-chart-0.2.0.tgz
EOF
```{{exec}}

Let's wait for the Definition `sample` to be Ready

```plain
kubectl wait definition sample --for condition=Ready=True --timeout=60s --namespace krateo-system
```{{exec}}

Check the Definition `sample` outputs

```plain
kubectl get definition sample --namespace krateo-system
```{{exec}}
