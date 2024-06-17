## Install Krateo Composable FinOps - operator-exporter
First, install the FinOps operator-exporter. This module is responsible for starting the Prometheus endpoint exporters and the respective scrapers.

Deploy the operator:
```plain
helm repo add krateo https://charts.krateo.io
helm repo update krateo
helm install exporter krateo/finops-operator-exporter -n finops --create-namespace
```{{exec}}

Let's wait for the deployment to be available

```plain
kubectl wait deployment exporter-finops-operator-exporter-controller-manager --for condition=Available=True --timeout=300s --namespace finops
```{{exec}}
