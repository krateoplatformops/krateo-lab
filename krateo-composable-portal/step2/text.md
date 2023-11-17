## Install Krateo Composable Portal krateo-gateway Helm chart
Now we install the chart

```plain
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: krateo-gateway
  namespace: krateo-system
type: Opaque
data:
  KRATEO_GATEWAY_CAKEY: L2V0Yy9rdWJlcm5ldGVzL3BraS9jYS5rZXkK
EOF
```{{exec}}

```plain
helm install krateo-gateway krateo/krateo-gateway  --create-namespace --namespace krateo-system --version 0.0.3 -f values.yaml
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment krateo-gateway --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}
