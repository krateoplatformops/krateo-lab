
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

And to verify we can run

```plain
kubectl get definition sample --namespace krateo-system
```{{exec}}
