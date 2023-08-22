
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
  chartUrl: https://github.com/krateoplatformops/postgresql-demo-chart/releases/download/12.8.3/postgresql-12.8.3.tgz
EOF
```{{exec}}

Let's wait for the Definition `sample` to be Ready

```plain
kubectl wait definition sample --for condition=Ready=True --timeout=300s --namespace krateo-system
```{{exec}}

Check the Definition `sample` outputs

```plain
kubectl get definition sample --namespace krateo-system
```{{exec}}
