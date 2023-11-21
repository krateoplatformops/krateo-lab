## Install Krateo Composable Portal krateo-gateway Helm chart
Let's ovverride the KRATEO_GATEWAY_DNS_NAMES default value

```plain
TRAFFIC_HOST1_30005={{TRAFFIC_HOST1_30005}}
prefix="https://"
foo=${{{TRAFFIC_HOST1_30005}}#"$prefix"}
echo "${foo}"
sed -i "s|localhost|${foo}|" values.yaml
```{{exec}}

Now we install the chart

```plain
helm install krateo-gateway krateo/krateo-gateway  --create-namespace --namespace krateo-system --version 0.1.1 -f values.yaml
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment krateo-gateway --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}

Let's patch the krateo-gateway to expose it on a fixed port:

```plain
cat > servicetype.json << EOF
- op: replace
  path: "/spec/type"
  value: NodePort
EOF
kubectl patch svc krateo-gateway -n krateo-system --type JSON --patch-file servicetype.json
cat > nodeport.json << EOF
- op: replace
  path: "/spec/ports/0/nodePort"
  value: 30005
EOF
kubectl patch svc krateo-gateway -n krateo-system --type JSON --patch-file nodeport.json
```{{exec}}
