
Install Krateo Composable Operations `core-provider` Helm chart

<br>

### Install core-provider
First we make sure we add Krateo Helm charts repo to our Helm client

```plain
helm repo add krateo https://charts.krateo.io
```{{exec}}

We can update the repo

```plain
helm repo update
```{{exec}}

Now we install the chart

```plain
helm install krateo-core-provider krateo/core-provider --create-namespace --namespace krateo-system --version 0.3.10
```{{exec}}

Let's wait for the deployment to be Available

```plain
kubectl wait deployment core-provider --for condition=Available=True --timeout=300s --namespace krateo-system
```{{exec}}
