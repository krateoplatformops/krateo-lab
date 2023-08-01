
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
helm install krateo-core-provider krateo/core-provider
```{{exec}}
