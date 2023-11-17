## Install Krateo Composable Portal krateo-bff Helm chart
First, we make sure we add the Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

We can update the repo

```plain
helm repo update
```{{exec}}

Now we install the chart

```plain
helm install krateo-bff krateo/krateo-bff --create-namespace --namespace krateo-system --version 0.1.1
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment krateo-bff --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}
