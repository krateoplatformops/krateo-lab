## Install Krateo Composable Portal krateo-gateway Helm chart
Now we install the chart

```plain
helm install krateo-gateway krateo/krateo-gateway  --create-namespace --namespace krateo-system --version 0.0.2
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment krateo-gateway --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}
